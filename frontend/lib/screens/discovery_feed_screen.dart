import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/skeleton_item.dart';
import '../widgets/product_card.dart';

class DiscoveryFeedScreen extends StatefulWidget {
  const DiscoveryFeedScreen({super.key});

  @override
  State<DiscoveryFeedScreen> createState() => _DiscoveryFeedScreenState();
}

class _DiscoveryFeedScreenState extends State<DiscoveryFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchDiscovery();
    });
  }

  void _addToCart(BuildContext context, Map<String, dynamic> product) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem(
      product['_id'],
      product['name'],
      product['price']?.toString() ?? '0',
      product['image'] ?? '',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} səbətə əlavə edildi 🛒'),
        duration: const Duration(seconds: 1),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleFavorite(BuildContext context, Map<String, dynamic> product) {
    final wishlist = Provider.of<WishlistProvider>(context, listen: false);
    wishlist.toggle(product['_id']);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final wishlist = Provider.of<WishlistProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text('discovery'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: productProvider.isLoading && productProvider.discoveryData.isEmpty
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonItem(width: 150, height: 28),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(3, (index) => const Padding(padding: EdgeInsets.only(right: 16), child: SkeletonProductCard())),
                  ),
                  const SizedBox(height: 32),
                  const SkeletonItem(width: 180, height: 28),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(3, (index) => const Padding(padding: EdgeInsets.only(right: 16), child: SkeletonItem(width: 280, height: 120, borderRadius: 20))),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => productProvider.fetchDiscovery(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('trending_foods'.tr(), Icons.whatshot, Colors.orange),
                    const SizedBox(height: 16),
                    _buildHorizontalList(productProvider.discoveryData['trending'] ?? [], wishlist),
                    const SizedBox(height: 32),
                    _buildSectionHeader('new_restaurants'.tr(), Icons.restaurant, Colors.blue),
                    const SizedBox(height: 16),
                    _buildRestaurantList(productProvider.discoveryData['restaurants'] ?? []),
                    const SizedBox(height: 32),
                    _buildSectionHeader('popular_now'.tr(), Icons.auto_awesome, Colors.purple),
                    const SizedBox(height: 16),
                    _buildGridList(productProvider.discoveryData['popular'] ?? [], wishlist),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      ],
    );
  }

  Widget _buildHorizontalList(List<dynamic> items, WishlistProvider wishlist) {
    if (items.isEmpty) return const Text('Heç bir məhsul tapılmadı');
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = Map<String, dynamic>.from(items[index]);
        final isFav = wishlist.isFavorite(item['_id']);
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: ProductCard(
              product: item,
              isFavorite: isFav,
              onFavoriteToggle: () => _toggleFavorite(context, item),
              onAddToCart: () => _addToCart(context, item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantList(List<dynamic> items) {
    if (items.isEmpty) return const Text('Yeni restoran yoxdur');
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: (item['profileImage'] != null && item['profileImage'].toString().isNotEmpty)
                    ? NetworkImage('http://localhost:5000${item['profileImage']}')
                    : null,
                child: item['profileImage'] == null ? const Icon(Icons.store) : null,
              ),
              title: Text(item['name'] ?? 'Restoran', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['address'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridList(List<dynamic> items, WishlistProvider wishlist) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = Map<String, dynamic>.from(items[index]);
        final isFav = wishlist.isFavorite(item['_id']);
        return ProductCard(
          product: item,
          isFavorite: isFav,
          onFavoriteToggle: () => _toggleFavorite(context, item),
          onAddToCart: () => _addToCart(context, item),
        );
      },
    );
  }
}
