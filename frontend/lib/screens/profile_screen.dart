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
import 'referral_screen.dart';
import 'pro_subscription_screen.dart';
import 'my_products_screen.dart';
import 'loyalty_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import '../providers/biometric_provider.dart';
import '../providers/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';

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
        title: Text('logout'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('logout_confirm'.tr(), style: const TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('no'.tr(), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
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
            child: Text('yes_logout'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: Text('settings'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar və Ad (Yenilənmiş Spacing)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.grey[800] : Colors.grey.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildAvatar(user, context, isDark),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user != null ? (user['name'] ?? 'user'.tr()) : 'loading'.tr(),
                            style: TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold, 
                              color: isDark ? Colors.white : Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              user != null ? (user['email'] ?? '') : '',
                              style: TextStyle(
                                fontSize: 13, 
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey.shade100, 
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_outlined, 
                          color: isDark ? Colors.white70 : Colors.black87, 
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('general'.tr(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),

              if (user != null && user['role'] == 'admin')
                _buidlMenuTile(Icons.admin_panel_settings_outlined, 'admin_dashboard'.tr(), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                }, isDark),
              
              _buidlMenuTile(Icons.shopping_bag_outlined, 'orders'.tr(), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
              }, isDark),
              _buidlMenuTile(Icons.inventory_2_outlined, 'my_products'.tr(), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProductsScreen()));
              }, isDark),
              _buidlMenuTile(Icons.location_on_outlined, 'address'.tr(), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen()));
              }, isDark),
              _buidlMenuTile(Icons.payment_outlined, 'payment_methods'.tr(), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
              }, isDark),
              _buidlMenuTile(Icons.notifications_outlined, 'notifications'.tr(), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              }, isDark),
              _buidlMenuTile(Icons.rocket_launch_outlined, 'pro_member'.tr(), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProSubscriptionScreen()));
              }, isDark),
              _buidlMenuTile(Icons.card_giftcard_outlined, 'referral_bonus'.tr(), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralScreen()));
              }, isDark),
              _buidlMenuTile(Icons.stars_rounded, 'loyalty_points'.tr(), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoyaltyDashboardScreen()));
              }, isDark),
              
              const SizedBox(height: 8),
              Consumer<BiometricProvider>(
                builder: (context, biometric, child) {
                  if (!biometric.isAvailable) return const SizedBox.shrink();
                  return SwitchListTile(
                    secondary: Icon(Icons.fingerprint, color: isDark ? Colors.white70 : Colors.black87),
                    title: Text('biometric_login'.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text('biometric_desc'.tr(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    value: biometric.isBiometricEnabled,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) => biometric.toggleBiometric(val),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  );
                },
              ),
              
              SwitchListTile(
                secondary: Icon(Icons.security, color: isDark ? Colors.white70 : Colors.black87),
                title: Text('2fa_login'.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text('2fa_desc'.tr(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                value: user?['isTwoFactorEnabled'] ?? false,
                activeColor: Colors.green,
                onChanged: (val) async {
                  final result = await authProvider.toggle2FA();
                  if (mounted && !result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('error'.tr()), backgroundColor: Colors.redAccent),
                    );
                  }
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              ),

              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Divider(height: 1),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('other'.tr(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              _buidlMenuTile(Icons.help_outline, 'help'.tr(), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpAndSupportScreen()));
              }, isDark),
              _buidlMenuTile(Icons.chat_outlined, 'live_chat'.tr(), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
              }, isDark),
              _buidlMenuTile(Icons.account_balance_wallet_outlined, 'wallet'.tr(), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
              }, isDark),
              _buidlMenuTile(Icons.language_outlined, '${'language'.tr()} (${context.locale.languageCode.toUpperCase()})', () {
                _showLanguageSelector(context);
              }, isDark),
              _buidlMenuTile(Icons.palette_outlined, '${'theme'.tr()} (${_getThemeName(context)})', () {
                _showThemeSelector(context);
              }, isDark),
              
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
                      Text('logout'.tr(), style: TextStyle(color: Colors.red.shade600, fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Dil Seçin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildLangTile(context, 'Azərbaycan', const Locale('az', 'AZ')),
              _buildLangTile(context, 'English', const Locale('en', 'US')),
              _buildLangTile(context, 'Русский', const Locale('ru', 'RU')),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getThemeName(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).themeMode;
    switch (theme) {
      case ThemeMode.system: return 'Sistem';
      case ThemeMode.light: return 'Açıq';
      case ThemeMode.dark: return 'Tünd';
    }
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Mövzu Seçin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildThemeTile(context, 'Sistem', ThemeMode.system, themeProvider),
              _buildThemeTile(context, 'Açıq', ThemeMode.light, themeProvider),
              _buildThemeTile(context, 'Tünd', ThemeMode.dark, themeProvider),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeTile(BuildContext context, String name, ThemeMode mode, ThemeProvider provider) {
    bool isSelected = provider.themeMode == mode;
    return ListTile(
      title: Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        provider.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLangTile(BuildContext context, String name, Locale locale) {
    bool isSelected = context.locale == locale;
    return ListTile(
      title: Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        context.setLocale(locale);
        Navigator.pop(context);
      },
    );
  }
}
