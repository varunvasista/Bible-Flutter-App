import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/local_bible_service.dart';
import '../../journal/models/verse_of_day.dart';

/// Resolves and caches a single Verse of the Day per calendar date.
///
/// The chosen verse remains stable for the whole day and refreshes the next day.
class VerseOfDayService {
  VerseOfDayService({required LocalBibleService localBible})
      : _localBible = localBible;

  static const _dateKey = 'last_verse_date';
  static const _referenceKey = 'last_verse_reference';
  static const _textKey = 'last_verse_text';

  static const List<String> _versePool = [
    'Isaiah 41:10',
    'John 3:16',
    'Matthew 11:28',
    'Proverbs 3:5',
    'Romans 8:28',
    'Joshua 1:9',
    'Philippians 4:6',
    '2 Timothy 1:7',
    'Psalm 23:1',
    'Lamentations 3:22',
  ];

  static const Map<String, String> _fallbackVerseText = {
    'Psalm 46:10': 'Be still, and know that I am God.',
    'Joshua 1:9':
        'Be strong and of a good courage; be not afraid, neither be thou dismayed: for the LORD thy God is with thee whithersoever thou goest.',
    'Proverbs 3:5':
        'Trust in the LORD with all thine heart; and lean not unto thine own understanding.',
    'Romans 8:28':
        'And we know that all things work together for good to them that love God, to them who are the called according to his purpose.',
    'Philippians 4:6':
        'Be careful for nothing; but in every thing by prayer and supplication with thanksgiving let your requests be made known unto God.',
  };

  final LocalBibleService _localBible;

  Future<VerseOfDay> getVerseOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateOnly(DateTime.now());

    final storedDate = prefs.getString(_dateKey);
    final storedReference = prefs.getString(_referenceKey);
    final storedText = prefs.getString(_textKey);
    if (storedDate == today &&
        storedReference != null &&
        storedReference.isNotEmpty &&
        storedText != null &&
        storedText.isNotEmpty) {
      return VerseOfDay(
        reference: storedReference,
        text: storedText,
        emotion: 'daily',
      );
    }

    final yesterdayReference = prefs.getString(_referenceKey);
    final reference = _pickReference(excluding: yesterdayReference);

    final verse = _resolveLocalVerse(
      reference,
      excluding: yesterdayReference,
    );

    await prefs.setString(_dateKey, today);
    await prefs.setString(_referenceKey, verse.reference);
    await prefs.setString(_textKey, verse.text);

    return verse;
  }

  String _pickReference({String? excluding}) {
    if (_versePool.length == 1) return _versePool.first;
    final random = Random();
    var candidate = _versePool[random.nextInt(_versePool.length)];
    if (excluding == null || excluding.isEmpty) return candidate;
    while (candidate == excluding) {
      candidate = _versePool[random.nextInt(_versePool.length)];
    }
    return candidate;
  }

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  VerseOfDay _resolveLocalVerse(String reference, {String? excluding}) {
    try {
      final fetched = _localBible.getPassage(reference);
      return VerseOfDay(
        reference: fetched.reference,
        text: fetched.text,
        emotion: 'daily',
      );
    } catch (_) {
      return _fallbackVerse(excluding: excluding);
    }
  }

  VerseOfDay _fallbackVerse({String? excluding}) {
    final references = _fallbackVerseText.keys.toList(growable: false);
    var candidate = references[Random().nextInt(references.length)];
    if (excluding != null && excluding.isNotEmpty && references.length > 1) {
      while (candidate == excluding) {
        candidate = references[Random().nextInt(references.length)];
      }
    }

    return VerseOfDay(
      reference: candidate,
      text: _fallbackVerseText[candidate]!,
      emotion: 'daily',
    );
  }
}
