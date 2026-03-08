import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/courier_provider.dart';

class CourierOrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const CourierOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cp = Provider.of<CourierProvider>(context, listen: false);
    final items = order['orderItems'] as List? ?? [];
    final addr = order['shippingAddress'] ?? {};
    final lat = addr['lat']?.toDouble() ?? 40.4093;
    final lng = addr['lng']?.toDouble() ?? 49.8671;
    final status = order['status']?.toString() ?? 'Kuryerə verildi';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('#${order['_id']?.toString().substring(18).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Column(
        children: [
          // Map
          SizedBox(
            height: 250,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              child: FlutterMap(
                options: MapOptions(initialCenter: LatLng(lat, lng), initialZoom: 15),
                children: [
                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lng),
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Address Card
                  _infoCard(
                    isDark,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.location_on, color: Colors.red, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Çatdırılma Ünvanı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('${addr['address'] ?? ''}, ${addr['city'] ?? ''}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Order items
                  const Text('Sifariş Məhsulları', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  ...items.map((item) => _buildItemRow(item, isDark)),
                  const SizedBox(height: 16),

                  // Price summary
                  _infoCard(
                    isDark,
                    child: Column(
                      children: [
                        _priceRow('Çatdırılma haqqı', '${order['deliveryFee']?.toStringAsFixed(2) ?? '2.00'} ₼', Colors.green),
                        const Divider(height: 20),
                        _priceRow('Cəmi', '${order['totalPrice']?.toStringAsFixed(2) ?? '0.00'} ₼', Theme.of(context).colorScheme.primary, isBold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Status action button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final newStatus = status == 'Kuryerə verildi' ? 'Qapınızdadır' : 'Çatdırıldı';
                        await cp.updateOrderStatus(order['_id'], newStatus);
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: Icon(status == 'Kuryerə verildi' ? Icons.delivery_dining : Icons.check_circle, color: Colors.white),
                      label: Text(
                        status == 'Kuryerə verildi' ? 'Yola çıxdım' : 'Çatdırıldı!',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: status == 'Kuryerə verildi' ? Colors.orange : const Color(0xFF2ECC71),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[200]),
            child: const Icon(Icons.fastfood_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
          Text('${item['qty']}x', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 8),
          Text('${item['price']} ₼', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _infoCard(bool isDark, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: child,
    );
  }

  Widget _priceRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: isBold ? 18 : 15, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}
