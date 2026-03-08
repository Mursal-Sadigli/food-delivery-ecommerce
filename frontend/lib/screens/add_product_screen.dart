import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_button.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
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

  final List<String> _categories = [
    'Elektronika',
    'Geyim',
    'Ev və Bağ',
    'Nəqliyyat',
    'Xidmətlər',
    'Digər'
  ];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      // Simulyasiya üçün gözləmə
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() => _isSubmitting = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Elanınız yoxlanışa göndərildi! ✅'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
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
      appBar: AppBar(
        title: const Text('Yeni Elan', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                label: 'Ad və Soyad',
                hint: 'Məs: Elvin Məmmədov',
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Ad daxil edin' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _sellerPhoneCtrl,
                label: 'Telefon nömrəsi',
                hint: 'Məs: 050 123 45 67',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Telefon daxil edin' : null,
              ),
              
              const SizedBox(height: 32),
              
              // Məhsul məlumatları başlığı
              _buildSectionTitle('Məhsul məlumatları'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _productNameCtrl,
                label: 'Məhsulun adı',
                hint: 'Məs: iPhone 14 Pro',
                icon: Icons.shopping_bag_outlined,
                validator: (v) => v!.isEmpty ? 'Məhsul adı daxil edin' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _priceCtrl,
                label: 'Qiymət (₼)',
                hint: 'Məs: 1500',
                icon: Icons.sell_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Qiymət daxil edin' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionCtrl,
                label: 'Xüsusiyyətlər / Təsvir',
                hint: 'Məhsul barədə ətraflı məlumat yazın...',
                icon: Icons.description_outlined,
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Təsvir daxil edin' : null,
              ),

              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _isSubmitting ? 'Göndərilir...' : 'Elanı Yerləşdir',
                  onPressed: _isSubmitting ? () {} : _submitForm,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
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
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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
