import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreeTerms = false;

  void _register() async {
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to Terms & Conditions.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.authError ?? 'Registration failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Column(
        children: [
          // ── Top dark section with logo ──
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Back button
                  Positioned(
                    top: 0,
                    left: 8,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            'assets/icons/food_app_logo.png',
                            height: 80,
                            errorBuilder: (_, __, ___) => Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.amber.shade700,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(Icons.restaurant, size: 40, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Step into a place where taste meets comfort and joy.',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom white section with form ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'David Johnson',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 18),

                    // Email
                    CustomTextField(
                      label: 'Email Address',
                      hint: 'yourmail@example.com',
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 18),

                    // Password
                    CustomTextField(
                      label: 'Enter Password',
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 12),

                    // Terms & Conditions
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreeTerms,
                            onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                            activeColor: const Color(0xFFE5A100),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                              children: [
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Create Account Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return CustomButton(
                          text: 'Create Account',
                          isLoading: authProvider.isLoading,
                          onPressed: _register,
                          color: const Color(0xFFE5A100),
                          textColor: Colors.white,
                        );
                      },
                    ),
                    const SizedBox(height: 24),



                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? ", style: TextStyle(color: Colors.black54, fontSize: 14)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Log In',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
