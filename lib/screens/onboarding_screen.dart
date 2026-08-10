import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      image: 'assets/images/player.png',
      title: 'Your Path to Play,\nAnytime, Anywhere.',
      subtitle: 'Find your court easily and play anywhere you want with us!',
    ),
    _OnboardingPage(
      image: 'assets/images/player.png',
      title: 'Book Courts,\nMeet Players.',
      subtitle: 'Reserve your favorite court and connect with players near you.',
    ),
    _OnboardingPage(
      image: 'assets/images/player.png',
      title: 'Improve Your Game\nwith Coaches.',
      subtitle: 'Find professional coaches and take your skills to the next level.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: _pages.map((p) => _buildPage(p, h)).toList(),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final active = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.neonGreen
                            : AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(Routes.signup),
                        child: const Text('Get Started'),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(Routes.home),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            side: const BorderSide(color: AppColors.darkBorder),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Continue as Guest',
                              style: TextStyle(
                                  color: AppColors.white60,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, double h) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: h * 0.55,
          child: ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.transparent],
              stops: [0.4, 1.0],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              page.image,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        Positioned(
          top: h * 0.52,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  page.subtitle,
                  style: const TextStyle(
                    color: AppColors.white60,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingPage {
  final String image, title, subtitle;
  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}