import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.auto_stories,
      title: 'Your Personal Library',
      description: 'Import and organize your PDF and EPUB books in one beautiful place. Your collection, always at your fingertips.',
    ),
    _OnboardingData(
      icon: Icons.search,
      title: 'Never Lose Your Place',
      description: 'Automatic reading progress tracking keeps you right where you left off. Pick up any book, anytime.',
    ),
    _OnboardingData(
      icon: Icons.chat_bubble_outline,
      title: 'Read Anywhere',
      description: 'A clean, distraction-free reading experience designed for comfortable long reading sessions.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 24),
                child: GestureDetector(
                  onTap: () => context.go('/auth'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Skip', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textMuted,
                    )),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon circle with gradient
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppTheme.orangeGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.ctaShadow,
                          ),
                          child: Icon(page.icon, size: 48, color: Colors.white),
                        ),
                        const SizedBox(height: 48),
                        // Title
                        Text(page.title, textAlign: TextAlign.center, style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
                        )),
                        const SizedBox(height: 16),
                        // Description
                        Text(page.description, textAlign: TextAlign.center, style: const TextStyle(
                          fontSize: 16, color: AppTheme.textSecondary, height: 1.5,
                        )),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dot indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.textPrimary : AppTheme.textMuted,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  );
                }),
              ),
            ),

            // CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    } else {
                      context.go('/auth');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingData({required this.icon, required this.title, required this.description});
}
