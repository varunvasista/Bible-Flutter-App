import 'package:flutter/material.dart';

import '../core/services/service_locator.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/onboarding_screen.dart';

class AppRouter {
  static const String onboarding = '/';
  static const String home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => settingsService.isOnboardingCompleted
              ? const HomeScreen()
              : const OnboardingScreen(),
        );
      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => settingsService.isOnboardingCompleted
              ? const HomeScreen()
              : const OnboardingScreen(),
        );
    }
  }
}
