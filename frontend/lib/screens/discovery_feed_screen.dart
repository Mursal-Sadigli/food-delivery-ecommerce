import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/product_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
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
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => productProvider.fetchDiscovery(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('trending_foods'.tr(), Icons.whatshot, Colors.orange),
                    const SizedBox(height: 16),
                    _buildTrendingList(productProvider.discoveryData['trending'] ?? []),
                    const SizedBox(height: 32),
                    _buildSectionHeader('new_restaurants'.tr(), Icons.restaurant, Colors.blue),
                    const SizedBox(height: 16),
                    _buildRestaurantList(productProvider.discoveryData['restaurants'] ?? []),
                    const SizedBox(height: 32),
                    _buildSectionHeader('popular_now'.tr(), Icons.auto_awesome, Colors.purple),
                    const SizedBox(height: 16),
                    _buildPopularList(productProvider.discoveryData['popular'] ?? []),
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

  Widget _buildTrendingList(List<dynamic> items) {
    if (items.isEmpty) return const Text('Heç bir məhsul tapılmadı');
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: ProductCard(
              product: item,
              onAddToCart: () {}, // Simple discovery mode
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
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
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
              onTap: () {},
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularList(List<dynamic> items) {
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
        return ProductCard(product: items[index]);
      },
    );
  }
}
