import 'package:flutter/material.dart';
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
          const SnackBar(content: Text('Sifarişləri yükləmək mümkün olmadı')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Sifarişlərim', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('Hələ heç bir sifarişiniz yoxdur'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final date = order['createdAt'] != null 
                        ? DateTime.tryParse(order['createdAt'])?.toLocal().toString().split(' ')[0] 
                        : 'Bilinmir';
                    final isDelivered = order['isDelivered'] == true;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text('Sifariş #${order['_id']?.toString().substring(0, 8) ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 8),
                              Text(date ?? '', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Çatdırılma Statusu: ${isDelivered ? 'Çatdırılıb' : 'Yolda'}', 
                            style: TextStyle(color: isDelivered ? (isDark ? Colors.greenAccent : Colors.green) : Colors.orange, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text('Məbləğ: \$${order['totalPrice']?.toStringAsFixed(2) ?? '0.00'}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    if (!isDelivered)
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen()));
                                        }, 
                                        child: Text('Canlı İzlə', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
                                      ),
                                    TextButton(onPressed: () {}, child: Text('Detallara Bax', style: TextStyle(color: Theme.of(context).colorScheme.primary))),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
