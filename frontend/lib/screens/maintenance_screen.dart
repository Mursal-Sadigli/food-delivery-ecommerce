import 'package:flutter/material.dart';


class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.black,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasiya (Lottie istifadə etmiriksə Icon)
            Icon(
              Icons.engineering_rounded,
              size: 100,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 30),
            const Text(
              'TEXNİKİ XİDMƏT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Platformamızda təkmilləşdirmə işləri aparılır. Tezliklə daha sürətli və keyfiyyətli xidmətlə yenidən aktiv olacağıq.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // "Geri qayıdacağıq" taymeri və ya animasiya
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade400),
            ),
            const SizedBox(height: 20),
            Text(
              'Xahiş edirik, bir az sonra yenidən cəhd edin.',
              style: TextStyle(
                color: Colors.orange.shade400,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
