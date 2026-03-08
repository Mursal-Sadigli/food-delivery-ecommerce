import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/custom_button.dart';
import '../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? productToEdit;
  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  // Şəxsi məlumatlar
  final _sellerNameCtrl = TextEditingController();
  final _sellerPhoneCtrl = TextEditingController();
  
  // Məhsul məlumatları
  final _productNameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String? _selectedCategory;
  
  File? _image;
  final _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _isSuccess = false;

  final List<Map<String, String>> _categories = [
    {'key': 'cat_food', 'value': 'food'},
    {'key': 'cat_drink', 'value': 'drink'},
    {'key': 'cat_vegetable', 'value': 'vegetable'},
    {'key': 'cat_fruit', 'value': 'fruit'},
    {'key': 'cat_sweets', 'value': 'sweets'},
    {'key': 'cat_meat_dairy', 'value': 'meat_dairy'},
    {'key': 'cat_fastfood', 'value': 'fastfood'},
    {'key': 'cat_other', 'value': 'other'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      final p = widget.productToEdit!;
      _productNameCtrl.text = p['name'] ?? '';
      _priceCtrl.text = p['price']?.toString() ?? '';
      _descriptionCtrl.text = p['description'] ?? '';
      _sellerNameCtrl.text = p['sellerName'] ?? '';
      
      // Kateqoriya yoxlanışı
      final exists = _categories.any((c) => c['value'] == p['category']);
      if (exists) {
        _selectedCategory = p['category'];
      }

      // Telefon nömrəsindən +994 hissəsini təmizlə
      String phone = p['sellerPhone'] ?? '';
      if (phone.startsWith('+994')) {
        _sellerPhoneCtrl.text = phone.replaceFirst('+994', '').trim();
      } else {
        _sellerPhoneCtrl.text = phone;
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _imageToBase64() async {
    if (_image == null) return null;
    final bytes = await _image!.readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      try {
        final imageBase64 = await _imageToBase64();
        
        // Telefon nömrəsini tam formatda göndər
        final fullPhone = '+994 ${_sellerPhoneCtrl.text.trim().replaceAll(RegExp(r'\s+'), ' ')}';

        final productData = {
          'name': _productNameCtrl.text.trim(),
          'price': double.tryParse(_priceCtrl.text) ?? 0,
          'description': _descriptionCtrl.text.trim(),
          'image': imageBase64 ?? (widget.productToEdit != null ? widget.productToEdit!['image'] : '/images/sample.jpg'),
          'category': _selectedCategory ?? 'Digər',
          'sellerName': _sellerNameCtrl.text.trim(),
          'sellerPhone': fullPhone,
          'brand': 'Xüsusi',
          'countInStock': 1,
        };

        if (widget.productToEdit != null) {
          // Update existing product
          await _apiService.put('/products/${widget.productToEdit!['_id']}', productData);
        } else {
          // Create new product
          await _apiService.post('/products', productData);
        }
        
        if (!mounted) return;

        setState(() {
          _isSubmitting = false;
          _isSuccess = true;
        });
      } catch (e) {
        setState(() => _isSubmitting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Xəta baş verdi: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _resetForm() {
    setState(() {
      _isSuccess = false;
      _image = null;
      _selectedCategory = null;
      _sellerNameCtrl.clear();
      _sellerPhoneCtrl.clear();
      _productNameCtrl.clear();
      _priceCtrl.clear();
      _descriptionCtrl.clear();
    });
  }

  @override
  void dispose() {
    _sellerNameCtrl.dispose();
    _sellerPhoneCtrl.dispose();
    _productNameCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.productToEdit != null ? 'Məhsulu Redaktə Et' : 'Yeni Məhsul Əlavə Et', 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return _isSuccess 
              ? _buildSuccessView() 
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
              // Şəkil yükləmə sahəsi
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey[500]),
                            const SizedBox(height: 12),
                            Text('Şəkil əlavə et', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Şəxsi məlumatlar başlığı
              _buildSectionTitle('Şəxsi məlumatlar'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _sellerNameCtrl,
                label: 'Adınız',
                hint: 'Tam adınızı daxil edin',
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Ad daxil edin' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _sellerPhoneCtrl,
                label: 'Telefon nömrəniz',
                hint: '51 591 47 94',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                prefixText: '+994 ',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                  _AzerbaijanPhoneFormatter(),
                ],
                validator: (v) {
                  if (v!.isEmpty) return 'Telefon daxil edin';
                  final digits = v.replaceAll(RegExp(r'\D'), '');
                  if (digits.length != 9) return 'Nömrə 9 rəqəmli olmalıdır';
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Məhsul məlumatları başlığı
              _buildSectionTitle('Məhsul məlumatları'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _productNameCtrl,
                label: 'Məhsulun adı',
                hint: 'Məsələn: Qırmızı pomidor',
                icon: Icons.shopping_bag_outlined,
                validator: (v) => v!.isEmpty ? 'Məhsul adı daxil edin' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _priceCtrl,
                label: 'Qiymət (₼)',
                hint: 'Məsələn: 2.50',
                icon: Icons.sell_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Qiymət daxil edin' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionCtrl,
                label: 'Məhsulun təsviri',
                hint: 'Məhsul barədə ətraflı məlumat yazın...',
                icon: Icons.description_outlined,
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Təsvir daxil edin' : null,
              ),

              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    CustomButton(
                      text: widget.productToEdit != null ? 'Məhsulu Yenilə' : 'Elanı Yerləşdir',
                      onPressed: _submitForm,
                      isLoading: _isSubmitting,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    },
  ),
);
}

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              widget.productToEdit != null ? 'Məhsul yeniləndi!' : 'Məhsulunuz uğurla yerləşdirildi!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Təbriklər! Məhsulunuz artıq satışdadır.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Geri Dön',
              onPressed: () {
                if (widget.productToEdit != null) {
                   Navigator.pop(context); // Redaktə ekranını bağla
                } else {
                   _resetForm();
                }
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Bu adətən MainScreen-də taba keçid üçün lazımdır, 
                // lakin forma daxilində təmizləmə bəs edir.
                _resetForm();
              },
              child: const Text('Ana səhifəyə qayıt'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefixText,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            prefixText: prefixText,
            prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
  Widget _buildDropdownField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kateqoriya', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          items: _categories.map((c) => DropdownMenuItem(value: c['value'], child: Text(c['key']!.tr()))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v),
          validator: (v) => v == null ? 'Kateqoriya seçin' : null,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.category_outlined, size: 20),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _AzerbaijanPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length <= 2) return newValue;
    
    var formatted = '';
    if (text.length > 2) {
      formatted += '${text.substring(0, 2)} ';
    }
    if (text.length > 5) {
      formatted += '${text.substring(2, 5)} ';
    } else if (text.length > 2) {
      formatted += text.substring(2);
    }
    
    if (text.length > 7) {
      formatted += '${text.substring(5, 7)} ';
      formatted += text.substring(7);
    } else if (text.length > 5) {
      formatted += text.substring(5);
    }

    return TextEditingValue(
      text: formatted.trim(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
