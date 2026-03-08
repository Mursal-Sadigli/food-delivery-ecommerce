import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/biometric_provider.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialScreen();
  }

  Future<void> _checkInitialScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final bool showHome = prefs.getBool('showHome') ?? false;
    final String? token = prefs.getString('token');

    if (mounted) {
      if (!showHome) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      } else if (token != null) {
        // Biometrik yoxlama
        final biometric = Provider.of<BiometricProvider>(context, listen: false);
        if (biometric.isBiometricEnabled) {
          final auhtenticated = await biometric.authenticate();
          if (!auhtenticated) {
            // Əgər imtina edilsə, yenidən sınamaq üçün burada qala bilər və ya login-ə ata bilər.
            // Biz burada sadəcə login-ə atmırıq, çünki token var.
            return; 
          }
        }
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'SmartMarket',
              style: GoogleFonts.outfit(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
