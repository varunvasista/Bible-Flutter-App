import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ReadingPosition {
  const ReadingPosition({
    required this.translation,
    required this.book,
    required this.chapter,
  });

  final String translation;
  final String book;
  final int chapter;

  factory ReadingPosition.fromJson(Map<String, dynamic> json) {
    return ReadingPosition(
      translation: json['translation'] as String,
      book: json['book'] as String,
      chapter: json['chapter'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'translation': translation,
        'book': book,
        'chapter': chapter,
      };
}

/// Stores the user's most recent Bible reading location locally.
class ReadingProgressService {
  static const _prefsKey = 'reading_progress_position';

  Future<void> saveProgress(String translation, String book, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final position = ReadingPosition(
      translation: translation,
      book: book,
      chapter: chapter,
    );
    _cached = position;
    await prefs.setString(_prefsKey, jsonEncode(position.toJson()));
  }

  ReadingPosition? _cached;

  Future<ReadingPosition?> getLastReadingPosition() async {
    if (_cached != null) return _cached;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _cached = ReadingPosition.fromJson(data);
      return _cached;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    _cached = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
