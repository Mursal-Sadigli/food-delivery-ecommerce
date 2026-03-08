import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Axtardığınız Hər Şeyi Tapın',
      subtitle: 'Minlərlə məhsul və restoran arasından seçiminizi edin. Hər şey bir toxunuş uzaqlığında.',
      image: Icons.search_rounded,
      color: const Color(0xFFFFE0B2),
      iconColor: const Color(0xFFFF6D00),
    ),
    OnboardingData(
      title: 'Sürətli və Təhlükəsiz Ödəniş',
      subtitle: 'Bank kartı, Apple Pay və ya Cüzdan ilə tam təhlükəsiz alış-verişin həzzini çıxarın.',
      image: Icons.account_balance_wallet_rounded,
      color: const Color(0xFFE1F5FE),
      iconColor: const Color(0xFF039BE5),
    ),
    OnboardingData(
      title: 'Qapınıza Qədər Sürətli Çatdırılma',
      subtitle: 'Sifarişlərinizi real-time xəritədə izləyin və ən qısa zamanda təslim alın.',
      image: Icons.delivery_dining_rounded,
      color: const Color(0xFFF1F8E9),
      iconColor: const Color(0xFF43A047),
    ),
  ];

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showHome', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPage(data: _pages[index]);
            },
          ),
          
          // Skip button
          if (_currentIndex < _pages.length - 1)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: () => _controller.animateToPage(
                  _pages.length - 1,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                ),
                child: Text(
                  'Ötür',
                  style: GoogleFonts.outfit(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
          // Bottom Controls
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: const Color(0xFFFF5722),
                    dotColor: Colors.grey.withOpacity(0.3),
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3,
                    spacing: 8,
                  ),
                ),
                
                GestureDetector(
                  onTap: () {
                    if (_currentIndex == _pages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 60,
                    width: _currentIndex == _pages.length - 1 ? 140 : 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5722).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _currentIndex == _pages.length - 1
                          ? Text(
                              'Başlayaq',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData image;
  final Color color;
  final Color iconColor;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.color,
    required this.iconColor,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Area
          Container(
            height: size.height * 0.4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: data.color.withOpacity(isDark ? 0.05 : 0.6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                data.image,
                size: 150,
                color: isDark ? data.iconColor.withOpacity(0.8) : data.iconColor,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.08),
          
          // Text Area
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
