import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import 'add_product_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  double _userRating = 0.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isReviewSubmitting = false;
  List<XFile> _selectedReviewImages = [];

  // Variations State
  int _selectedSizeIndex = 0;
  List<int> _selectedAddons = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchRecommendations(
        category: widget.product['category'],
        exclude: widget.product['_id'],
      );
    });
  }

  // Calculate dynamic price
  double get _currentPrice {
    double basePrice = double.tryParse(widget.product['price']?.toString() ?? '0') ?? 0;
    
    // Add size price diff
    final List<dynamic> sizes = widget.product['sizes'] ?? [];
    if (sizes.isNotEmpty && _selectedSizeIndex < sizes.length) {
      basePrice += double.tryParse(sizes[_selectedSizeIndex]['price']?.toString() ?? '0') ?? 0;
    }

    // Add addons price
    final List<dynamic> addons = widget.product['addons'] ?? [];
    if (addons.isNotEmpty) {
      for (int i in _selectedAddons) {
        basePrice += double.tryParse(addons[i]['price']?.toString() ?? '0') ?? 0;
      }
    }

    return basePrice * _quantity;
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  Future<void> _submitReview() async {
    final comment = _reviewController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zəhmət olmasa rəyinizi yazın.')),
      );
      return;
    }
    
    if (_userRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zəhmət olmasa məhsulu ulduzla qiymətləndirin.')),
      );
      return;
    }

    setState(() => _isReviewSubmitting = true);

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    // Real images would be uploaded to a bucket first, then URLs sent. 
    // Here we simulate with file paths or placeholders.
    final success = await productProvider.addReview(
      widget.product['_id'], 
      _userRating, 
      comment,
      images: _selectedReviewImages.map((e) => e.path).toList(),
    );

    setState(() => _isReviewSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rəyiniz uğurla əlavə edildi! Məhsullar yenilənir...')),
      );
      _reviewController.clear();
      setState(() => _userRating = 0.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Siz artıq rəy bildirmisiniz və ya xəta baş verdi.')),
      );
    }
  }

  void _showDeleteDialog() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Məhsulu sil'),
        content: const Text('Bu məhsulu silmək istədiyinizə əminsiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
          TextButton(
            onPressed: () async {
              final success = await productProvider.deleteProduct(widget.product['_id']);
              if (mounted) {
                Navigator.pop(ctx); // Dialogu bağla (dialog context-i ilə)
                if (success) {
                  navigator.pop(); // Detal ekranını bağla (əvvəlcədən alınmış navigator ilə)
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Məhsul silindi'), backgroundColor: Colors.green),
                  );
                }
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Şəkil URL-i yoxlayırıq və əgər relative /images/... isə mütləq formaya salırıq
    String rawImageUrl = widget.product['image']?.toString() ?? '';
    String imageUrl = rawImageUrl.isNotEmpty && !rawImageUrl.startsWith('http') && !rawImageUrl.startsWith('data:image')
        ? 'http://localhost:5000$rawImageUrl' 
        : rawImageUrl;

    final title = widget.product['name']?.toString() ?? 'Yemək';
    final description = widget.product['description']?.toString() ?? 'Təzə və ləzzətli yemək.';
    final rating = widget.product['rating']?.toString() ?? '0.0';
    
    // Gələn reviews massivi
    final List<dynamic> reviews = widget.product['reviews'] ?? [];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final currentUser = authProvider.user;
    final bool isOwner = currentUser != null && 
                        widget.product['user'] != null && 
                        (currentUser['_id'] == widget.product['user'] || 
                         (widget.product['user'] is Map && currentUser['_id'] == widget.product['user']['_id']));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: [
          if (isOwner) ...[
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductScreen(productToEdit: widget.product),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              tooltip: 'Redaktə et',
            ),
            IconButton(
              onPressed: _showDeleteDialog,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Sil',
            ),
          ],
          IconButton(
            onPressed: () {
              Share.share('Bu ləzzətli yeməyə bax! ${widget.product['name']}\nQiymət: ${widget.product['price']} ₼\nSmartFood-dan sifariş et!');
            },
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Container(
              height: 350,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: imageUrl.isEmpty
                  ? const Center(child: Icon(Icons.fastfood, size: 100, color: Colors.white))
                  : (imageUrl.startsWith('data:image')
                      ? Image.memory(
                          base64Decode(imageUrl.split(',').last),
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 100, color: Colors.grey)),
                        )),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.amber.withOpacity(0.2) : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              rating.length > 3 ? rating.substring(0, 3) : rating,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_currentPrice.toStringAsFixed(2)} ₼',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Variations (Sizes)
                  if ((widget.product['sizes'] ?? []).isNotEmpty) ...[
                    const Text('Ölçü seçin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: List.generate((widget.product['sizes'] as List).length, (index) {
                        final size = widget.product['sizes'][index];
                        final isSelected = _selectedSizeIndex == index;
                        final double extra = double.tryParse(size['price']?.toString() ?? '0') ?? 0;
                        return ChoiceChip(
                          label: Text('${size['name']}' + (extra > 0 ? ' (+${extra.toStringAsFixed(2)} ₼)' : '')),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _selectedSizeIndex = index),
                          selectedColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black)),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Add-ons
                  if ((widget.product['addons'] ?? []).isNotEmpty) ...[
                    const Text('Əlavələr', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...List.generate((widget.product['addons'] as List).length, (index) {
                      final addon = widget.product['addons'][index];
                      final isSelected = _selectedAddons.contains(index);
                      final double extra = double.tryParse(addon['price']?.toString() ?? '0') ?? 0;
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedAddons.add(index);
                            } else {
                              _selectedAddons.remove(index);
                            }
                          });
                        },
                        title: Text('${addon['name']}'),
                        subtitle: Text('+${extra.toStringAsFixed(2)} ₼', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Theme.of(context).colorScheme.primary,
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                  
                  // Say Artırıb-Azaltmaq Modulu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Miqdar',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _decrementQuantity,
                              icon: Icon(Icons.remove, color: isDark ? Colors.white : Colors.black),
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: _incrementQuantity,
                              icon: Icon(Icons.add, color: isDark ? Colors.white : Colors.black),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Bu yemək haqqında',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.6),
                  ),
                  
                  const Divider(height: 60, thickness: 1),

                  // REVIEWS SECTİON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rəylər',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${reviews.length} Rəy',
                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mövcud Rəylərin Siyahısı
                  if (reviews.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Hələ heç bir rəy yoxdur. İlk rəyi siz yazın!', style: TextStyle(color: Colors.grey.shade500)),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final rev = reviews[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    rev['name'] ?? 'İstifadəçi',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Row(
                                    children: List.generate(5, (starIdx) {
                                      final starRating = (rev['rating'] ?? 0);
                                      return Icon(
                                        starIdx < starRating ? Icons.star : Icons.star_border,
                                        color: Colors.orange,
                                        size: 14,
                                      );
                                    }),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                rev['comment'] ?? '',
                                style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade800, height: 1.4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                rev['createdAt'] != null 
                                  ? rev['createdAt'].toString().substring(0, 10) 
                                  : '',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              )
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 32),
                  const Text('Rəy Yaz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Ulduz seçimi
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _userRating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            _userRating = (index + 1).toDouble();
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  
                  // Rəy Mətni
                  TextField(
                    controller: _reviewController,
                    maxLines: 4,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Fikrinizi buraya yazın...',
                      hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Image picker for review
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final images = await picker.pickMultiImage();
                          if (images.isNotEmpty) {
                            setState(() => _selectedReviewImages.addAll(images));
                          }
                        },
                        icon: const Icon(Icons.add_a_photo_outlined),
                        tooltip: 'Şəkil əlavə et',
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _selectedReviewImages.isEmpty
                            ? Text('Şəkil əlavə edilməyib', style: TextStyle(color: Colors.grey[500], fontSize: 12))
                            : SizedBox(
                                height: 50,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedReviewImages.length,
                                  itemBuilder: (context, idx) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Stack(
                                        children: [
                                          Image.file(File(_selectedReviewImages[idx].path), width: 50, height: 50, fit: BoxFit.cover),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: GestureDetector(
                                              onTap: () => setState(() => _selectedReviewImages.removeAt(idx)),
                                              child: Container(color: Colors.black54, child: const Icon(Icons.close, size: 14, color: Colors.white)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Rəy Göndər Düyməsi
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isReviewSubmitting ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isReviewSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Rəyi Göndər', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  
                  const Divider(height: 60, thickness: 1),

                  // RECOMMENDATIONS SECTION
                  if (productProvider.recommendations.isNotEmpty) ...[
                    const Text(
                      'Sizə maraqlı ola bilər',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: productProvider.recommendations.length,
                        itemBuilder: (context, index) {
                          final prod = productProvider.recommendations[index];
                          return Container(
                            width: 170,
                            margin: const EdgeInsets.only(right: 16),
                            child: ProductCard(
                              product: prod,
                              onAddToCart: () {
                                Provider.of<CartProvider>(context, listen: false).addItem(
                                  prod['_id'], prod['name'], prod['price'].toString(), prod['image']
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10))
          ],
        ),
        child: CustomButton(
          text: 'Səbətə Əlavə Et (${_currentPrice.toStringAsFixed(2)} ₼)',
          onPressed: () {
             final cartProvider = Provider.of<CartProvider>(context, listen: false);

             // Extract selected size string
             String? selectedSizeStr;
             final List<dynamic> sizes = widget.product['sizes'] ?? [];
             if (sizes.isNotEmpty && _selectedSizeIndex < sizes.length) {
               selectedSizeStr = sizes[_selectedSizeIndex]['name'];
             }

             // Extract selected addons string
             String? selectedAddonsStr;
             final List<dynamic> addons = widget.product['addons'] ?? [];
             if (addons.isNotEmpty && _selectedAddons.isNotEmpty) {
               selectedAddonsStr = _selectedAddons.map((i) => addons[i]['name']).join(', ');
             }

             // Add single item with the total variations quantity, or loop 
             cartProvider.addItem(
               widget.product['_id'],
               title, 
               (_currentPrice / _quantity).toStringAsFixed(2), // pass unit price of variation
               imageUrl,
               quantity: _quantity,
               size: selectedSizeStr,
               addons: selectedAddonsStr,
             );

             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('$_quantity ədəd $title səbətə əlavə edildi 🛒')),
             );
             Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
