import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/courier_provider.dart';

class CourierRegistrationScreen extends StatefulWidget {
  const CourierRegistrationScreen({super.key});

  @override
  State<CourierRegistrationScreen> createState() => _CourierRegistrationScreenState();
}

class _CourierRegistrationScreenState extends State<CourierRegistrationScreen> {
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  String _vehicleType = 'motorcycle';
  bool _isLoading = false;

  Future<void> _register() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefon nömrəsini daxil edin.'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isLoading = true);
    final success = await Provider.of<CourierProvider>(context, listen: false).registerCourier(
      phone: _phoneController.text.trim(),
      vehicleType: _vehicleType,
      licenseNumber: _licenseController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🚴 Kuryer qeydiyyatı tamamlandı!'), backgroundColor: Colors.green),
      );
      Navigator.pushReplacementNamed(context, '/courier-home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xəta baş verdi. Yenidən cəhd edin.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF7C59F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 60),
                    Icon(Icons.delivery_dining, size: 72, color: Colors.white),
                    SizedBox(height: 12),
                    Text('Kuryer kimi qeydiyyat', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('SmartFood şəbəkəsinə qoşul', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ),
            backgroundColor: const Color(0xFFFF6B35),
            elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _sectionTitle('Nəqliyyat növü'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _vehicleChip('bicycle', '🚲 Velosiped'),
                      const SizedBox(width: 12),
                      _vehicleChip('motorcycle', '🏍 Motosiklet'),
                      const SizedBox(width: 12),
                      _vehicleChip('car', '🚗 Avtomobil'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _sectionTitle('Telefon nömrəsi *'),
                  const SizedBox(height: 10),
                  _buildTextField(_phoneController, '+994 () __ __ __', Icons.phone_outlined, TextInputType.phone),
                  const SizedBox(height: 20),
                  _sectionTitle('Sürücülük vəsiqəsi (ixtiyari)'),
                  const SizedBox(height: 10),
                  _buildTextField(_licenseController, 'AA 12 345678', Icons.credit_card_outlined, TextInputType.text),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 4,
                        shadowColor: const Color(0xFFFF6B35).withOpacity(0.4),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Kuryer kimi qeydiyyatdan keç', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Qeydiyyat tamamlandıqda hesabınız kuryer kimi fəaliyyət göstərəcək.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 12),
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

  Widget _vehicleChip(String value, String label) {
    final isSelected = _vehicleType == value;
    return GestureDetector(
      onTap: () => setState(() => _vehicleType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent, width: 2),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : null, fontSize: 13)),
      ),
    );
  }

  Widget _sectionTitle(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, TextInputType keyboard) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    );
  }
}
