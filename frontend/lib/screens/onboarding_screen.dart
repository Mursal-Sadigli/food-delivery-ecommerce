import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'login_screen.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showHome', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == 2;
            });
          },
          children: [
            _buildPage(
              color: Colors.blue.shade50,
              urlImage: 'assets/images/onboarding1.png', // We'll use icons as fallback
              title: 'Axtardığınız Hər Şey',
              subtitle: 'Minlərlə məhsul arasından istədiyiniz məhsulu asanlıqla tapın.',
              icon: Icons.search_rounded,
            ),
            _buildPage(
              color: Colors.green.shade50,
              urlImage: 'assets/images/onboarding2.png',
              title: 'Sürətli və Təhlükəsiz Ödəniş',
              subtitle: 'Məlumatlarınız tam qorunur. Ödənişləri rahat və sürətli edin.',
              icon: Icons.security_rounded,
            ),
            _buildPage(
              color: Colors.purple.shade50,
              urlImage: 'assets/images/onboarding3.png',
              title: 'Sürətli Çatdırılma',
              subtitle: 'Sifarişləriniz ən qısa zamanda qapınıza qədər gətirilsin.',
              icon: Icons.local_shipping_rounded,
            ),
          ],
        ),
      ),
      bottomSheet: isLastPage
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.white,
              height: 80,
              child: CustomButton(
                text: 'Başlayaq',
                onPressed: _completeOnboarding,
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 80,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _controller.jumpToPage(2),
                    child: const Text('Keç', style: TextStyle(fontSize: 16)),
                  ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Theme.of(context).colorScheme.primary,
                      dotColor: Colors.grey.shade300,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
                    child: const Text('Növbəti', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPage({
    required Color color,
    required String urlImage,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      color: Colors.white, // color was parameter, using white for clean look
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 120, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 64),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
