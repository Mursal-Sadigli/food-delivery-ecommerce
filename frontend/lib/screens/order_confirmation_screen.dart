import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'order_tracking_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Uğurlu ikon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 42),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Sifarişiniz Üçün\nTəşəkkür Edirik!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Sifarişiniz uğurla qəbul edildi!\nÇatdırılmanı Sifarişlər bölməsindən izləyə bilərsiniz',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.6),
              ),
              const Spacer(flex: 2),
              // Ana səhifə düyməsi
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Ana Səhifəyə Qayıt', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 14),
              // Sifariş izlə düyməsi
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const OrderTrackingScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Sifarişi İzlə', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Başqa bir şey də sifariş edə bilərsiniz',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
