import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/api_service.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await ApiService().get('/orders/myorders');
      if (mounted) {
        setState(() {
          _orders = response is List ? response : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error'.tr())),
        );
      }
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'preparing': return 'order_status_preparing'.tr();
      case 'cooking': return 'order_status_cooking'.tr();
      case 'on the way': return 'order_status_on_the_way'.tr();
      case 'delivered': return 'order_status_delivered'.tr();
      default: return status;
    }
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'preparing': return Colors.blue;
      case 'cooking': return Colors.orange;
      case 'on the way': return Colors.deepPurple;
      case 'delivered': return isDark ? Colors.greenAccent : Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'preparing': return Icons.receipt_long_outlined;
      case 'cooking': return Icons.soup_kitchen_outlined;
      case 'on the way': return Icons.delivery_dining_outlined;
      case 'delivered': return Icons.check_circle_outline;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('orders'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('no_orders'.tr(), style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final date = order['createdAt'] != null 
                          ? DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(order['createdAt']).toLocal())
                          : 'N/A';
                      final status = order['status']?.toString() ?? (order['isDelivered'] == true ? 'delivered' : 'preparing');
                      final isDelivered = status.toLowerCase() == 'delivered';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.03), 
                              blurRadius: 20, 
                              offset: const Offset(0, 10)
                            ),
                          ],
                          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[100]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status, isDark).withOpacity(0.1),
                                ),
                                child: Row(
                                  children: [
                                    Icon(_getStatusIcon(status), color: _getStatusColor(status, isDark), size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getStatusText(status),
                                      style: TextStyle(
                                        color: _getStatusColor(status, isDark),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      date,
                                      style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${'order_id'.tr()} #${order['_id']?.toString().substring(order['_id'].toString().length - 6).toUpperCase() ?? 'N/A'}',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${(order['orderItems'] as List?)?.length ?? 0} ${'items'.tr()}',
                                              style: TextStyle(color: Colors.grey, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${order['totalPrice']?.toStringAsFixed(2) ?? '0.00'} ₼',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    const Divider(height: 1),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        if (!isDelivered)
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen()));
                                              },
                                              icon: const Icon(Icons.location_on_outlined, size: 18),
                                              label: Text('track_order'.tr()),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            ),
                                          ),
                                        if (!isDelivered) const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _showOrderDetails(order),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                                            ),
                                            child: Text(
                                              'order_details'.tr(),
                                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = order['orderItems'] as List? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('order_details'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 32),
                itemBuilder: (context, index) {
                  final item = items[index];
                  String itemImg = item['image']?.toString() ?? '';
                  if (itemImg.isNotEmpty && !itemImg.startsWith('http')) {
                    itemImg = 'http://localhost:5000$itemImg';
                  }

                  return Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: itemImg.isEmpty 
                          ? Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.fastfood))
                          : Image.network(itemImg, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.broken_image))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'] ?? 'Yemək', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            if (item['size'] != null) Text(item['size'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            if (item['addons'] != null) Text(item['addons'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${item['qty']} x ${item['price']} ₼', style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text('${(item['qty'] * (double.tryParse(item['price'].toString()) ?? 0)).toStringAsFixed(2)} ₼', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  _summaryRow('tax'.tr(), '${order['taxPrice']?.toStringAsFixed(2) ?? '0.00'} ₼', isDark),
                  const SizedBox(height: 8),
                  _summaryRow('shipping'.tr(), '${order['shippingPrice']?.toStringAsFixed(2) ?? '0.00'} ₼', isDark),
                  const Divider(height: 24),
                  _summaryRow('total'.tr(), '${order['totalPrice']?.toStringAsFixed(2) ?? '0.00'} ₼', isDark, isTotal: true),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('close'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isDark, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        Text(value, style: TextStyle(fontSize: isTotal ? 20 : 16, fontWeight: FontWeight.bold, color: isTotal ? Theme.of(context).colorScheme.primary : (isDark ? Colors.white : Colors.black87))),
      ],
    );
  }
}
