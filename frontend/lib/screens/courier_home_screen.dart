import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/courier_provider.dart';
import '../providers/auth_provider.dart';
import 'courier_order_detail_screen.dart';
import 'courier_earnings_screen.dart';

class CourierHomeScreen extends StatefulWidget {
  const CourierHomeScreen({super.key});

  @override
  State<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends State<CourierHomeScreen> {
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cp = Provider.of<CourierProvider>(context, listen: false);
      cp.fetchProfile();
      cp.fetchAssignedOrders();
    });
  }

  Future<void> _toggleOnline(CourierProvider cp) async {
    setState(() => _isToggling = true);
    await cp.setAvailability(!cp.isOnline);
    setState(() => _isToggling = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Consumer<CourierProvider>(
      builder: (context, cp, _) {
        final isOnline = cp.isOnline;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: isOnline ? const Color(0xFF2ECC71) : Colors.grey[700],
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOnline
                            ? [const Color(0xFF27AE60), const Color(0xFF2ECC71)]
                            : [Colors.grey[800]!, Colors.grey[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Salam, Kuryer 🚴', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                    Text(
                                      auth.user?['name'] ?? 'Kuryer',
                                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourierEarningsScreen())),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                    child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 24),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Online/Offline Toggle
                            GestureDetector(
                              onTap: _isToggling ? null : () => _toggleOnline(cp),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(isOnline ? Icons.circle : Icons.circle_outlined, color: isOnline ? Colors.greenAccent : Colors.white54, size: 14),
                                    const SizedBox(width: 10),
                                    Text(
                                      _isToggling ? 'Yüklənir...' : (isOnline ? '🟢 Onlayn — Sifariş qəbul edir' : '⚪ Oflayn — Sifariş almır'),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false).logout();
                    },
                  ),
                ],
              ),

              // Stats row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _statCard('Aktiv Sifarişlər', cp.assignedOrders.length.toString(), Icons.local_shipping_outlined, Colors.orange, isDark),
                      const SizedBox(width: 16),
                      _statCard('Bu gün', '${cp.earnings?['today'] ?? 0} ₼', Icons.today_outlined, Colors.green, isDark),
                      const SizedBox(width: 16),
                      _statCard('Reytinq', '${cp.profile?['rating'] ?? 5.0}⭐', Icons.star_outlined, Colors.amber, isDark),
                    ],
                  ),
                ),
              ),

              // Active orders title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Aktiv Sifarişlər', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      TextButton.icon(
                        onPressed: () => cp.fetchAssignedOrders(),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Yenilə'),
                      ),
                    ],
                  ),
                ),
              ),

              // Orders list
              cp.isLoading
                  ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())))
                  : cp.assignedOrders.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(48),
                              child: Column(
                                children: [
                                  Icon(Icons.delivery_dining, size: 80, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text(isOnline ? 'Sifariş gözlənilir...' : 'Sifariş almaq üçün Onlayn keçin',
                                      style: TextStyle(color: Colors.grey[500], fontSize: 16), textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) {
                              final order = cp.assignedOrders[i];
                              return _buildOrderCard(order, isDark, cp);
                            },
                            childCount: cp.assignedOrders.length,
                          ),
                        ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isDark, CourierProvider cp) {
    final status = order['status']?.toString() ?? 'Kuryerə verildi';
    final items = (order['orderItems'] as List?)?.length ?? 0;
    final total = order['totalPrice']?.toStringAsFixed(2) ?? '0.00';
    final addr = order['shippingAddress']?['address'] ?? 'Ünvan yoxdur';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${order['_id']?.toString().substring(18).toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(status, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(addr, style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.fastfood_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('$items məhsul', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const Spacer(),
                Text('$total ₼', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourierOrderDetailScreen(order: order))),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Detallar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final newStatus = status == 'Kuryerə verildi' ? 'Qapınızdadır' : 'Çatdırıldı';
                      await cp.updateOrderStatus(order['_id'], newStatus);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(status == 'Kuryerə verildi' ? '🚴 Yolayım' : '✅ Çatdırdım', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
