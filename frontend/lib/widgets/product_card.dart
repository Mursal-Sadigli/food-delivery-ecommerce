import 'package:flutter/material.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = product['image']?.toString() ?? '';
    final title = product['name']?.toString() ?? 'Məhsul';
    final description = product['description']?.toString() ?? '';
    final price = product['price']?.toString() ?? '0';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Şəkil
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl.startsWith('http') ? imageUrl : 'http://127.0.0.1:5000$imageUrl',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[100],
                              child: const Center(child: Icon(Icons.fastfood, size: 40, color: Colors.grey)),
                            ),
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: const Center(child: Icon(Icons.fastfood, size: 40, color: Colors.grey)),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isFavorite ? Colors.red.withOpacity(0.8) : Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Mətn
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(description, style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Qiymət', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('$price ₼', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Əlavə', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
