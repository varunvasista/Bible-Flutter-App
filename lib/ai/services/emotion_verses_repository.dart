import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Loads and serves the emotion → verse-reference mapping from
/// `assets/data/emotion_verses.json`.
///
/// This singleton is initialised once in [main] and shared by both
/// [SpiritualGuidanceService] and [JournalReflectionService], avoiding
/// repeated asset I/O on every service init.
class EmotionVersesRepository {
  static const _assetPath = 'assets/data/emotion_verses.json';

  Map<String, List<String>> _data = {};
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final raw = await rootBundle.loadString(_assetPath);
      _data = (jsonDecode(raw) as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, (value as List<dynamic>).cast<String>()),
      );
      _loaded = true;
      debugPrint(
          'EmotionVersesRepository: loaded ${_data.length} emotion entries');
    } catch (e) {
      debugPrint('EmotionVersesRepository: init failed: $e');
    }
  }

  /// Returns verse references for [emotion].
  ///
    /// Falls back to the `peace` entry, then a hard-coded default.
  List<String> versesFor(String emotion) =>
      _data[emotion] ??
      _data['peace'] ??
      const ['John 14:27'];

  bool get isLoaded => _loaded;
}
