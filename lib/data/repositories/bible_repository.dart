import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/bible_book.dart';
import '../models/bible_chapter.dart';
import '../models/bible_testament.dart';
import '../models/bible_verse.dart';

/// In-memory repository for all Bible translations.
///
/// Call [init] once at startup (loads the default translation eagerly).
/// Additional translations are lazy-loaded via [ensureLoaded] before use.
class BibleRepository {
  static const String defaultTranslation = 'KJV';

  // ── Translation registry ──────────────────────────────────────────────────

  /// All translations supported by this app.
  /// Key = short code used by the app (cache key, UI label).
  /// Value = Flutter asset path under assets/bible/.
  static const Map<String, String> availableTranslations = {
    'KJV': 'assets/bible/kjv.json',
    'NIV': 'assets/bible/niv.json',
    'ESV': 'assets/bible/amp.json',
    'NLT': 'assets/bible/nlt.json',
  };

  static const Map<String, String> translationFullNames = {
    'KJV': 'King James Version',
    'NIV': 'New International Version',
    'ESV': 'English Standard Version',
    'NLT': 'New Living Translation',
  };

  final Map<String, Bible> _cache = {};

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Eagerly loads [defaultTranslation] at app startup.
  Future<void> init() => ensureLoaded(defaultTranslation);

  /// Loads and caches [translation] if it is not already in memory.
  ///
  /// Safe to call multiple times for the same key.
  Future<void> ensureLoaded(String translation) async {
    final key = translation.toUpperCase();
    if (_cache.containsKey(key)) return;

    final path = availableTranslations[key];
    if (path == null) {
      throw ArgumentError(
        'Translation "$translation" is not configured. '
        'Available: ${availableTranslations.keys.join(', ')}',
      );
    }

    final rawJson = await rootBundle.loadString(path);
    _cache[key] = Bible.fromJson(jsonDecode(rawJson) as Map<String, dynamic>);
  }

  /// Whether [translation] has already been loaded into memory.
  bool isLoaded(String translation) =>
      _cache.containsKey(translation.toUpperCase());

  // ── Translation-level ─────────────────────────────────────────────────────

  List<String> getTranslations() => availableTranslations.keys.toList();

  List<String> getLoadedTranslations() => _cache.keys.toList(growable: false);

  String getFullName(String translation) =>
      translationFullNames[translation.toUpperCase()] ?? translation;

  // ── Testament-level ───────────────────────────────────────────────────────

  List<BibleTestament> getTestaments(String translation) =>
      _require(translation).testaments;

  // ── Book-level ────────────────────────────────────────────────────────────

  List<BibleBook> getBooks(String translation, String testamentName) {
    return _require(translation)
        .testaments
        .firstWhere(
          (t) => t.name.toLowerCase() == testamentName.toLowerCase(),
          orElse: () =>
              throw ArgumentError('Testament "$testamentName" not found.'),
        )
        .books;
  }

  // ── Chapter-level ─────────────────────────────────────────────────────────

  List<BibleChapter> getChapters(String translation, String bookName) =>
      List.unmodifiable(
        _require(translation).getBook(bookName)?.chapters ?? const [],
      );

  List<int> getChapterNumbers(String translation, String bookName) =>
      getChapters(translation, bookName).map((c) => c.chapter).toList();

  // ── Verse-level ───────────────────────────────────────────────────────────

  List<BibleVerse> getVerses(
    String translation,
    String bookName,
    int chapterNumber,
  ) =>
      List.unmodifiable(
        _require(translation).getChapter(bookName, chapterNumber)?.verses ??
            const [],
      );

  BibleChapter? getChapter(
    String translation,
    String bookName,
    int chapterNumber,
  ) =>
      _require(translation).getChapter(bookName, chapterNumber);

  BibleVerse? getVerse(
    String translation,
    String bookName,
    int chapterNumber,
    int verseNumber,
  ) =>
      _require(translation).getVerse(bookName, chapterNumber, verseNumber);

  // ── Convenience ───────────────────────────────────────────────────────────

  List<String> get allBookNames => _require(defaultTranslation)
      .testaments
      .expand((t) => t.books)
      .map((b) => b.name)
      .toList(growable: false);

  // ── Internal ──────────────────────────────────────────────────────────────

  Bible _require(String translation) {
    final key = translation.toUpperCase();
    final bible = _cache[key];
    if (bible == null) {
      throw StateError(
        'Translation "$translation" is not loaded. '
        'Await bibleRepo.ensureLoaded("$translation") first.',
      );
    }
    return bible;
  }
}
