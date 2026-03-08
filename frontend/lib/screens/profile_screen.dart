import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'orders_screen.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';
import 'chat_screen.dart';
import 'wallet_screen.dart';
import '../providers/biometric_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchProfile();
    });
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Çıxış Et', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Hesabınızdan çıxmaq istədiyinizə əminsiniz?', style: TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Xeyr', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Bəli, çıxış et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text('Tənzimləmələr', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar və Ad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.grey[800] : Colors.grey.shade100,
                        boxShadow: [
                          BoxShadow(color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                        ]
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildAvatar(user, context, isDark),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user != null ? (user['name'] ?? 'İstifadəçi') : 'Yüklənir...',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user != null ? (user['email'] ?? '') : '',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey.shade100, shape: BoxShape.circle),
                        child: Icon(Icons.edit_outlined, color: isDark ? Colors.white70 : Colors.black87, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Ümumi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              
              _buidlMenuTile(Icons.shopping_bag_outlined, 'Sifarişlərim', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
              }, isDark),
              _buidlMenuTile(Icons.location_on_outlined, 'Çatdırılma Ünvanları', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen()));
              }, isDark),
              _buidlMenuTile(Icons.payment_outlined, 'Ödəniş Üsulları', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
              }, isDark),
              _buidlMenuTile(Icons.notifications_outlined, 'Bildirişlər', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              }, isDark),
              
              const SizedBox(height: 8),
              Consumer<BiometricProvider>(
                builder: (context, biometric, child) {
                  if (!biometric.isAvailable) return const SizedBox.shrink();
                  return SwitchListTile(
                    secondary: Icon(Icons.fingerprint, color: isDark ? Colors.white70 : Colors.black87),
                    title: Text('Biometrik Giriş', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
                    subtitle: const Text('FaceID / Barmaq izi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    value: biometric.isBiometricEnabled,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) => biometric.toggleBiometric(val),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  );
                },
              ),

              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Divider(height: 1),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Digər', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              _buidlMenuTile(Icons.help_outline, 'Yardım və Dəstək', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpAndSupportScreen()));
              }, isDark),
              _buidlMenuTile(Icons.chat_outlined, 'Canlı Dəstək', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
              }, isDark),
              _buidlMenuTile(Icons.account_balance_wallet_outlined, 'Mənim Cüzdanım', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
              }, isDark),
              _buidlMenuTile(Icons.language_outlined, 'Dil (Azərbaycan)', () {}, isDark),
              
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => _logout(context),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.logout, color: Colors.red.shade600, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Text('Hesabdan Çıx', style: TextStyle(color: Colors.red.shade600, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic>? user, BuildContext context, bool isDark) {
    if (user != null && user['profileImage'] != null && user['profileImage'] != '') {
      if (user['profileImage'].toString().startsWith('http')) {
        return Image.network(user['profileImage'], fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.person, size: 40, color: isDark ? Colors.grey[600] : Colors.grey.shade400));
      } else {
        return Image.memory(base64Decode(user['profileImage'].toString().split(',').last), fit: BoxFit.cover);
      }
    }
    return Icon(Icons.person, size: 40, color: isDark ? Colors.grey[600] : Colors.grey.shade400);
  }

  Widget _buidlMenuTile(IconData icon, String title, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: isDark ? Colors.white70 : Colors.black87, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87))),
            Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
