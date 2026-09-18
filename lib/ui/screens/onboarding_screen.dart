import 'package:flutter/material.dart';
import '../../core/services/service_locator.dart';
import '../../routes/app_router.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  final List<OnboardingData> _screens = [
    OnboardingData(
      title: 'Begin Your Journey with God',
      description:
          "Read Scripture daily, reflect on God's Word, and strengthen your relationship with Christ.",
      imagePath: 'assets/images/read_bible.png',
      buttonText: 'Get Started',
    ),
    OnboardingData(
      title: 'Grow Together in Faith',
      description:
          'Create lasting habits of prayer, Bible study, and meaningful conversations with your family.',
      imagePath: 'assets/images/family_bible.png',
      buttonText: 'Continue',
    ),
    OnboardingData(
      title: 'Live the Word Every Day',
      description:
          'Follow devotionals, write reflections, complete Bible plans, and grow closer to Christ every day.',
      imagePath: 'assets/images/group_study.png',
      buttonText: 'Continue',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    await settingsService.saveOnboardingCompleted(true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    }
  }

  void _onNextPage() {
    if (_currentPage < _screens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  color: const Color(0xFF000000),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 335,
                    height: 335,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Advent Bible',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                  height: 1.0,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _screens.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = _screens[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Large circular illustration container
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Image.asset(
                                data.imagePath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Title
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.white
                                    : AppColors.textDark,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          data.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.white.withOpacity(0.7)
                                    : AppColors.textLight,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom section: indicators and buttons
            Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: 24.0,
                top: 8.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _screens.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.white
                                  : AppColors.secondary)
                              : AppColors.greyMedium,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000000),
                        foregroundColor: const Color(0xFFFFFFFF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        _screens[_currentPage].buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Skip button below (only for screens 1 and 2)
                  AnimatedOpacity(
                    opacity: _currentPage < _screens.length - 1 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: _currentPage < _screens.length - 1
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextButton(
                              onPressed: _completeOnboarding,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textMuted,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 24.0,
                                ),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(
                            height:
                                52), // Preserve space to avoid layout shifts
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;
  final String buttonText;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.buttonText,
  });
}
