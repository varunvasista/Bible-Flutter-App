import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bible_app/features/settings/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService preferred translation flow tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should return true for hasPreferredTranslation on initial run', () async {
      final service = SettingsService();
      await service.init();
      expect(service.hasPreferredTranslation, isTrue);
    });

    test('should return KJV for preferredTranslation on initial run', () async {
      final service = SettingsService();
      await service.init();
      expect(service.preferredTranslation, 'KJV');
    });

    test('should return true for hasPreferredTranslation after saving translation', () async {
      final service = SettingsService();
      await service.init();
      await service.savePreferredTranslation('NLT');
      expect(service.hasPreferredTranslation, isTrue);
      expect(service.preferredTranslation, 'NLT');
    });

    test('should load preferred translation from storage on init', () async {
      SharedPreferences.setMockInitialValues({
        'settings_preferred_translation': 'ASV',
      });
      final service = SettingsService();
      await service.init();
      expect(service.hasPreferredTranslation, isTrue);
      expect(service.preferredTranslation, 'ASV');
    });

    test('should return false for isOnboardingCompleted on initial run', () async {
      final service = SettingsService();
      await service.init();
      expect(service.isOnboardingCompleted, isFalse);
    });

    test('should return true for isOnboardingCompleted after saving true', () async {
      final service = SettingsService();
      await service.init();
      await service.saveOnboardingCompleted(true);
      expect(service.isOnboardingCompleted, isTrue);
    });

    test('should load onboardingCompleted from storage on init', () async {
      SharedPreferences.setMockInitialValues({
        'settings_onboarding_completed': true,
      });
      final service = SettingsService();
      await service.init();
      expect(service.isOnboardingCompleted, isTrue);
    });
  });
}
