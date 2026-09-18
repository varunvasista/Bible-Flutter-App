import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _translationKey = 'settings_preferred_translation';
  static const _reminderHourKey = 'settings_reminder_hour';
  static const _reminderMinuteKey = 'settings_reminder_minute';
  static const _readingPlanKey = 'settings_reading_plan';
  static const _onboardingCompletedKey = 'settings_onboarding_completed';

  String _preferredTranslation = 'KJV';
  bool _hasPreferredTranslation = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  String _selectedReadingPlan = '30 Day Gospel Plan';
  bool _onboardingCompleted = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _hasPreferredTranslation = true;
    _preferredTranslation = prefs.getString(_translationKey) ?? 'KJV';

    final hour = prefs.getInt(_reminderHourKey) ?? 8;
    final minute = prefs.getInt(_reminderMinuteKey) ?? 0;
    _reminderTime = TimeOfDay(hour: hour, minute: minute);

    _selectedReadingPlan =
        prefs.getString(_readingPlanKey) ?? '30 Day Gospel Plan';
    _onboardingCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  String get preferredTranslation => _preferredTranslation;
  bool get hasPreferredTranslation => _hasPreferredTranslation;
  TimeOfDay get reminderTime => _reminderTime;
  String get selectedReadingPlan => _selectedReadingPlan;
  bool get isOnboardingCompleted => _onboardingCompleted;

  Future<void> saveOnboardingCompleted(bool completed) async {
    _onboardingCompleted = completed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  Future<void> savePreferredTranslation(String translation) async {
    _preferredTranslation = translation.toUpperCase();
    _hasPreferredTranslation = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_translationKey, _preferredTranslation);
  }

  Future<String> getPreferredTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    _preferredTranslation = prefs.getString(_translationKey) ?? _preferredTranslation;
    return _preferredTranslation;
  }

  Future<void> saveReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHourKey, time.hour);
    await prefs.setInt(_reminderMinuteKey, time.minute);
  }

  Future<TimeOfDay> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    _reminderTime = TimeOfDay(
      hour: prefs.getInt(_reminderHourKey) ?? _reminderTime.hour,
      minute: prefs.getInt(_reminderMinuteKey) ?? _reminderTime.minute,
    );
    return _reminderTime;
  }

  Future<void> saveSelectedReadingPlan(String planName) async {
    _selectedReadingPlan = planName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readingPlanKey, planName);
  }

  Future<String> getSelectedReadingPlan() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedReadingPlan =
        prefs.getString(_readingPlanKey) ?? _selectedReadingPlan;
    return _selectedReadingPlan;
  }
}
