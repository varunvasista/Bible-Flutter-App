import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/bible_verse.dart';

/// Stores bookmarked verses locally using SharedPreferences.
class BookmarkService {
  static const _prefsKey = 'bible_bookmarks';

  final Map<String, BibleVerse> _cache = {};

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? const [];
    for (final item in raw) {
      try {
        final data = jsonDecode(item) as Map<String, dynamic>;
        final verse = BibleVerse(
          translation: data['translation'] as String?,
          book: data['book'] as String?,
          chapter: data['chapter'] as int?,
          verse: data['verse'] as int,
          text: data['text'] as String,
        );
        _cache[_buildId(verse)] = verse;
      } catch (_) {
        // Skip malformed rows.
      }
    }
  }

  Future<void> addBookmark(BibleVerse verse) async {
    _cache[_buildId(verse)] = verse;
    await _persist();
  }

  Future<void> removeBookmark(BibleVerse verse) async {
    _cache.remove(_buildId(verse));
    await _persist();
  }

  List<BibleVerse> getBookmarks() => _cache.values.toList(growable: false)
    ..sort((a, b) {
      final ta = '${a.translation}|${a.book}|${a.chapter}|${a.verse}';
      final tb = '${b.translation}|${b.book}|${b.chapter}|${b.verse}';
      return ta.compareTo(tb);
    });

  bool isBookmarked(BibleVerse verse) => _cache.containsKey(_buildId(verse));

  Future<void> toggleBookmark(BibleVerse verse) async {
    final id = _buildId(verse);
    if (_cache.containsKey(id)) {
      _cache.remove(id);
    } else {
      _cache[id] = verse;
    }
    await _persist();
  }

  String _buildId(BibleVerse verse) {
    if (verse.translation == null || verse.book == null || verse.chapter == null) {
      throw ArgumentError(
        'BibleVerse must include translation, book, and chapter for bookmarking.',
      );
    }
    return '${verse.translation}_${verse.book}_${verse.chapter}_${verse.verse}';
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final rows = _cache.values
        .map((v) => jsonEncode({
              'translation': v.translation,
              'book': v.book,
              'chapter': v.chapter,
              'verse': v.verse,
              'text': v.text,
            }))
        .toList(growable: false);
    await prefs.setStringList(_prefsKey, rows);
  }

  Future<void> clearAll() async {
    _cache.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
