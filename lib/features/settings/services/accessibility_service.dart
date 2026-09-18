import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityService {
  static const _fontScaleKey = 'a11y_font_scale';
  static const _highContrastKey = 'a11y_high_contrast';
  static const _largeVerseTextKey = 'a11y_large_verse_text';

  double _fontScale = 1.0;
  bool _highContrast = false;
  bool _largeVerseText = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _fontScale = (prefs.getDouble(_fontScaleKey) ?? 1.0).clamp(0.8, 1.4);
    _highContrast = prefs.getBool(_highContrastKey) ?? false;
    _largeVerseText = prefs.getBool(_largeVerseTextKey) ?? false;
  }

  double get fontScale => _fontScale;
  bool get highContrast => _highContrast;
  bool get largeVerseText => _largeVerseText;

  Future<void> saveFontScale(double scale) async {
    _fontScale = scale.clamp(0.8, 1.4);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, _fontScale);
  }

  Future<double> getFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    _fontScale = (prefs.getDouble(_fontScaleKey) ?? _fontScale).clamp(0.8, 1.4);
    return _fontScale;
  }

  Future<void> saveHighContrast(bool enabled) async {
    _highContrast = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, enabled);
  }

  Future<bool> getHighContrast() async {
    final prefs = await SharedPreferences.getInstance();
    _highContrast = prefs.getBool(_highContrastKey) ?? _highContrast;
    return _highContrast;
  }

  Future<void> saveLargeVerseText(bool enabled) async {
    _largeVerseText = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_largeVerseTextKey, enabled);
  }

  Future<bool> getLargeVerseText() async {
    final prefs = await SharedPreferences.getInstance();
    _largeVerseText = prefs.getBool(_largeVerseTextKey) ?? _largeVerseText;
    return _largeVerseText;
  }
}
