import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';

class ProSubscriptionScreen extends StatelessWidget {
  const ProSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = Provider.of<WalletProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFFFD700); // Gold
    final secondaryColor = const Color(0xFFFFA000); // Dark Gold

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF0F2F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.3),
                    child: Center(
                      child: Icon(Icons.rocket_launch_rounded, size: 120, color: Colors.white.withOpacity(0.5)),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      const Text(
                        'SmartMarket PRO',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Premium Təcrübənin Dadını Çıxar',
                        style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            backgroundColor: primaryColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cari Balans', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                            SizedBox(height: 4),
                            Text('Balansınız kifayətdir', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(
                          '${wallet.balance.toStringAsFixed(2)} ₼',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'PRO Üstünlüklər',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildBenefitCard(
                    icon: Icons.delivery_dining_rounded,
                    title: 'Pulsuz Çatdırılma',
                    subtitle: 'Bütün restoranlardan limitsiz pulsuz çatdırılma.',
                    isDark: isDark,
                  ),
                  _buildBenefitCard(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Eksklüziv Endirimlər',
                    subtitle: 'Yalnız PRO üzvlər üçün 20%-dək əlavə endirimlər.',
                    isDark: isDark,
                  ),
                  _buildBenefitCard(
                    icon: Icons.support_agent_rounded,
                    title: 'Prioritet Dəstək',
                    subtitle: 'Problemləriniz saniyələr içində həll olunacaq.',
                    isDark: isDark,
                  ),
                  _buildBenefitCard(
                    icon: Icons.star_rounded,
                    title: 'SmartPoints x2',
                    subtitle: 'Hər sifarişdən ikiqat çox bonus şansını qazan.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 40),
                  if (!wallet.isPro) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: primaryColor.withOpacity(0.5), width: 2),
                      ),
                      child: Column(
                        children: [
                          const Text('Cəmi 9.99 ₼ / Ay', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: wallet.balance < 9.99 
                                ? null 
                                : () async {
                                    bool success = await wallet.purchasePro();
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Təbriklər! Artıq PRO üzvüsünüz! 🚀')),
                                      );
                                    }
                                  },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: const Text('Abunəliyi Başlat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          if (wallet.balance < 9.99) ...[
                             const SizedBox(height: 12),
                             TextButton(
                               onPressed: () => _showDepositDialog(context, wallet),
                               child: const Text('Balansı artır (9.99 ₼ lazımdır)', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                             ),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 48),
                          const SizedBox(height: 16),
                          const Text('PRO Abunəlik Aktivdir', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(height: 8),
                          Text(
                            'Yenilənmə tarixi: ${wallet.subscriptionExpiry != null ? DateFormat('dd.MM.yyyy').format(wallet.subscriptionExpiry!) : "-"}',
                            style: TextStyle(color: Colors.green.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({required IconData icon, required String title, required String subtitle, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog(BuildContext context, WalletProvider wallet) {
    final controller = TextEditingController(text: '10.0');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Balans Artır'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Abunəlik üçün balansınızı artırın.', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Məbləğ (₼)',
                suffixText: '₼',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                final success = await wallet.deposit(amount);
                if (success) {
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text('Artır'),
          ),
        ],
      ),
    );
  }
}
