import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();

  void _resetPassword() async {
    final token = _tokenController.text.trim();
    final newPassword = _passwordController.text.trim();

    if (token.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zəhmət olmasa bütün xanaları doldurun')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(widget.email, token, newPassword);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifrəniz uğurla yeniləndi!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xəta baş verdi. Kodu və ya şifrəni yoxlayın.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifrəni Sıfırla'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.email} ünvanına göndərilən 6 rəqəmli kodu və yeni şifrənizi daxil edin.',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Bərpa kodu',
              hint: '123456',
              controller: _tokenController,
              prefixIcon: Icons.security_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Yeni şifrə',
              hint: 'Yeni şifrənizi daxil edin',
              controller: _passwordController,
              isPassword: true,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 32),
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return CustomButton(
                  text: 'Şifrəni yenilə',
                  isLoading: auth.isLoading,
                  onPressed: _resetPassword,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
