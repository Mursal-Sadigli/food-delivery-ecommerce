import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import 'add_product_screen.dart';

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
  final List<XFile> _selectedReviewImages = [];

  int _selectedSizeIndex = 0;
  final List<int> _selectedAddons = [];

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

  double get _currentPrice {
    double basePrice = double.tryParse(widget.product['price']?.toString() ?? '0') ?? 0;
    
    final List<dynamic> sizes = widget.product['sizes'] ?? [];
    if (sizes.isNotEmpty && _selectedSizeIndex < sizes.length) {
      basePrice += double.tryParse(sizes[_selectedSizeIndex]['price']?.toString() ?? '0') ?? 0;
    }

    final List<dynamic> addons = widget.product['addons'] ?? [];
    if (addons.isNotEmpty) {
      for (int i in _selectedAddons) {
        basePrice += double.tryParse(addons[i]['price']?.toString() ?? '0') ?? 0;
      }
    }

    return basePrice * _quantity;
  }

  void _incrementQuantity() {
    setState(() => _quantity++);
  }

  void _decrementQuantity() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  Future<void> _submitReview() async {
    final comment = _reviewController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('write_comment_error'.tr()), backgroundColor: Colors.red));
      return;
    }
    
    if (_userRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('rate_error'.tr()), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isReviewSubmitting = true);
    final success = await Provider.of<ProductProvider>(context, listen: false).addReview(
      widget.product['_id'], 
      _userRating, 
      comment,
      images: _selectedReviewImages.map((e) => e.path).toList(),
    );
    setState(() => _isReviewSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('review_success'.tr()), backgroundColor: Colors.green));
        _reviewController.clear();
        setState(() {
          _userRating = 0.0;
          _selectedReviewImages.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('review_error'.tr()), backgroundColor: Colors.red));
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('delete_product'.tr()),
        content: Text('delete_confirm'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
          TextButton(
            onPressed: () async {
              final success = await Provider.of<ProductProvider>(context, listen: false).deleteProduct(widget.product['_id']);
              if (mounted) {
                Navigator.pop(ctx);
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('product_deleted'.tr()), backgroundColor: Colors.green));
                }
              }
            },
            child: Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    
    String rawImageUrl = widget.product['image']?.toString() ?? '';
    String imageUrl = rawImageUrl.isNotEmpty && !rawImageUrl.startsWith('http') && !rawImageUrl.startsWith('data:image')
        ? 'http://localhost:5000$rawImageUrl' 
        : rawImageUrl;

    final title = widget.product['name']?.toString() ?? 'Food';
    final description = widget.product['description']?.toString() ?? 'Delicious food.';
    final rating = widget.product['rating']?.toString() ?? '0.0';
    final List<dynamic> reviews = widget.product['reviews'] ?? [];

    final currentUser = authProvider.user;
    final bool isOwner = currentUser != null && 
                        widget.product['user'] != null && 
                        (currentUser['_id'] == widget.product['user'] || 
                         (widget.product['user'] is Map && currentUser['_id'] == widget.product['user']['_id']));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                ),
              ),
            ),
            actions: [
              if (isOwner) ...[
                _buildCircleAction(Icons.edit_outlined, Colors.blue, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductScreen(productToEdit: widget.product)));
                }),
                const SizedBox(width: 8),
                _buildCircleAction(Icons.delete_outline, Colors.red, _showDeleteDialog),
                const SizedBox(width: 8),
              ],
              _buildCircleAction(Icons.share_outlined, Colors.white, () {
                Share.share('share_product_msg'.tr(namedArgs: {'name': title, 'price': widget.product['price'].toString()}));
              }),
              const SizedBox(width: 8),
              _buildCircleAction(Icons.favorite_border, Colors.white, () {}),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_${widget.product['_id']}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl.isEmpty
                        ? const Center(child: Icon(Icons.fastfood, size: 100, color: Colors.grey))
                        : (imageUrl.startsWith('data:image')
                            ? Image.memory(base64Decode(imageUrl.split(',').last), fit: BoxFit.cover)
                            : Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 100)))),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.6)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange, size: 18),
                              const SizedBox(width: 4),
                              Text(rating.length > 3 ? rating.substring(0, 3) : rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('${(_currentPrice / _quantity).toStringAsFixed(2)} ₼', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 24),
                    
                    if ((widget.product['sizes'] ?? []).isNotEmpty) ...[
                      Text('select_size'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (widget.product['sizes'] as List).length,
                          itemBuilder: (context, index) {
                            final size = widget.product['sizes'][index];
                            final isSelected = _selectedSizeIndex == index;
                            final double extra = double.tryParse(size['price']?.toString() ?? '0') ?? 0;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ChoiceChip(
                                label: Text('${size['name']}' + (extra > 0 ? ' (+${extra.toStringAsFixed(2)} ₼)' : '')),
                                selected: isSelected,
                                onSelected: (_) => setState(() => _selectedSizeIndex = index),
                                selectedColor: Theme.of(context).colorScheme.primary,
                                labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    if ((widget.product['addons'] ?? []).isNotEmpty) ...[
                      Text('addons'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...List.generate((widget.product['addons'] as List).length, (index) {
                        final addon = widget.product['addons'][index];
                        final isSelected = _selectedAddons.contains(index);
                        final double extra = double.tryParse(addon['price']?.toString() ?? '0') ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Colors.transparent),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) _selectedAddons.add(index);
                                else _selectedAddons.remove(index);
                              });
                            },
                            title: Text('${addon['name']}', style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            subtitle: Text('+${extra.toStringAsFixed(2)} ₼', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('quantity'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey.shade100, borderRadius: BorderRadius.circular(30)),
                          child: Row(
                            children: [
                              _buildQuantityBtn(Icons.remove, _decrementQuantity, isDark),
                              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                              _buildQuantityBtn(Icons.add, _incrementQuantity, isDark),
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 32),
                    Text('about_product'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(description, style: TextStyle(fontSize: 15, color: isDark ? Colors.grey[400] : Colors.grey[700], height: 1.6)),
                    
                    const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Divider()),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('reviews'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${reviews.length} ${'reviews'.tr()}', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (reviews.isEmpty)
                      Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('no_reviews'.tr(), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500]))))
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final rev = reviews[index];
                          return _buildReviewItem(rev, isDark);
                        },
                      ),

                    const SizedBox(height: 32),
                    _buildAddReviewCard(isDark),
                    
                    if (productProvider.recommendations.isNotEmpty) ...[
                      const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Divider()),
                      Text('may_like'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
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
                                  Provider.of<CartProvider>(context, listen: false).addItem(prod['_id'], prod['name'], prod['price'].toString(), prod['image']);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: CustomButton(
            text: 'add_to_cart_with_price'.tr(namedArgs: {'price': _currentPrice.toStringAsFixed(2)}),
            onPressed: () {
               final cartProvider = Provider.of<CartProvider>(context, listen: false);
               String? sizeStr;
               if (widget.product['sizes'] != null && (widget.product['sizes'] as List).isNotEmpty) {
                 sizeStr = widget.product['sizes'][_selectedSizeIndex]['name'];
               }
               String? addonsStr;
               if (_selectedAddons.isNotEmpty) {
                 addonsStr = _selectedAddons.map((i) => widget.product['addons'][i]['name']).join(', ');
               }

               cartProvider.addItem(
                 widget.product['_id'],
                 title, 
                 (_currentPrice / _quantity).toStringAsFixed(2),
                 imageUrl,
                 quantity: _quantity,
                 size: sizeStr,
                 addons: addonsStr,
               );

               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('added_to_cart_msg'.tr(namedArgs: {'quantity': _quantity.toString(), 'name': title})), behavior: SnackBarBehavior.floating));
               Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, Color color, VoidCallback onTap) {
    return Center(
      child: CircleAvatar(
        backgroundColor: Colors.black26,
        child: IconButton(icon: Icon(icon, color: color, size: 20), onPressed: onTap),
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.white, shape: BoxShape.circle, boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
        child: Icon(icon, size: 20, color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildReviewItem(dynamic rev, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rev['name'] ?? 'Guest', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(children: List.generate(5, (i) => Icon(i < (rev['rating'] ?? 0) ? Icons.star : Icons.star_border, color: Colors.orange, size: 14))),
            ],
          ),
          const SizedBox(height: 8),
          Text(rev['comment'] ?? '', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildAddReviewCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.blue.shade50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('write_review'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (i) => IconButton(
              icon: Icon(i < _userRating ? Icons.star : Icons.star_border, color: Colors.orange, size: 28),
              onPressed: () => setState(() => _userRating = (i + 1).toDouble()),
            )),
          ),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'review_hint'.tr(),
              filled: true,
              fillColor: isDark ? Colors.black26 : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final images = await picker.pickMultiImage();
                  if (images.isNotEmpty) setState(() => _selectedReviewImages.addAll(images));
                },
                icon: const Icon(Icons.add_a_photo_outlined),
              ),
              Expanded(
                child: _selectedReviewImages.isEmpty
                  ? Text('no_photo'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 12))
                  : SizedBox(height: 40, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _selectedReviewImages.length, itemBuilder: (ctx, idx) => Padding(padding: const EdgeInsets.only(right: 8), child: Image.file(File(_selectedReviewImages[idx].path), width: 40, fit: BoxFit.cover)))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isReviewSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: _isReviewSubmitting ? const CircularProgressIndicator(color: Colors.white) : Text('submit_review'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
