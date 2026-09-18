import 'package:flutter/foundation.dart';

import '../../data/models/bible_verse.dart';
import '../../data/repositories/bible_repository.dart';

/// Offline Bible lookup service backed by the bundled NLT dataset.
class LocalBibleService {
  LocalBibleService({
    required BibleRepository repository,
    this.translation = BibleRepository.defaultTranslation,
  }) : _repository = repository;

  final BibleRepository _repository;
  final String translation;
  final Map<String, String> _bookAliases = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  static const _fallbackVerse = BibleVerse(
    reference: 'Psalm 46:10',
    verse: 10,
    text: 'Be still, and know that I am God.',
    translation: BibleRepository.defaultTranslation,
    book: 'Psalms',
    chapter: 46,
  );

  Future<void> loadBible() async {
    try {
      debugPrint('Loading Bible dataset...');
      await _repository.ensureLoaded(translation);
      _seedAliases();
      _isLoaded = true;
      debugPrint('Bible dataset loaded successfully');
    } catch (e) {
      debugPrint('Bible dataset failed to load: $e');
      _bookAliases.clear();
      _isLoaded = false;
    }
  }

  BibleVerse? getVerse(String book, int chapter, int verseNumber) {
    if (!_isLoaded) {
      return null;
    }

    final canonicalBook = _canonicalBookName(book);
    if (canonicalBook == null) {
      return null;
    }

    final verse = _repository.getVerse(
      translation,
      canonicalBook,
      chapter,
      verseNumber,
    );
    if (verse == null) {
      return null;
    }

    return BibleVerse(
      reference: '$canonicalBook $chapter:$verseNumber',
      verse: verseNumber,
      text: verse.text,
      translation: translation,
      book: canonicalBook,
      chapter: chapter,
    );
  }

  BibleVerse getPassage(String reference) {
    if (!_isLoaded) {
      return _fallbackVerse;
    }

    try {
      final parsed = _parseReference(reference);
      if (parsed == null) {
        return _fallbackVerse;
      }

      final verses = <BibleVerse>[];
      for (var verseNumber = parsed.startVerse;
          verseNumber <= parsed.endVerse;
          verseNumber++) {
        final verse = getVerse(parsed.book, parsed.chapter, verseNumber);
        if (verse != null) {
          verses.add(verse);
        }
      }

      if (verses.isEmpty) {
        return _fallbackVerse;
      }

      final text = verses.map((verse) => verse.text.trim()).join(' ');
      final normalizedReference = parsed.startVerse == parsed.endVerse
          ? '${parsed.book} ${parsed.chapter}:${parsed.startVerse}'
          : '${parsed.book} ${parsed.chapter}:${parsed.startVerse}-${parsed.endVerse}';

      return BibleVerse(
        reference: normalizedReference,
        verse: parsed.startVerse,
        text: text,
        translation: translation,
        book: parsed.book,
        chapter: parsed.chapter,
      );
    } catch (_) {
      return _fallbackVerse;
    }
  }

  String? _canonicalBookName(String book) {
    _seedAliases();
    return _bookAliases[_normalizeBook(book)];
  }

  void _seedAliases() {
    if (_bookAliases.isNotEmpty) {
      return;
    }

    for (final book in _repository.allBookNames) {
      _bookAliases[_normalizeBook(book)] = book;
    }

    _bookAliases['psalm'] = 'Psalms';
    _bookAliases['psalms'] = 'Psalms';
    _bookAliases['songofsongs'] = 'Song of Songs';
    _bookAliases['songofsolomon'] = 'Song of Songs';
  }

  _ParsedReference? _parseReference(String reference) {
    final trimmed = reference.trim();
    final match =
        RegExp(r'^(.+?)\s+(\d+):(\d+)(?:-(\d+))?$').firstMatch(trimmed);
    if (match == null) {
      return null;
    }

    final book = _canonicalBookName(match.group(1)!);
    if (book == null) {
      return null;
    }
    final chapter = int.parse(match.group(2)!);
    final startVerse = int.parse(match.group(3)!);
    final endVerse = int.parse(match.group(4) ?? match.group(3)!);

    return _ParsedReference(
      book: book,
      chapter: chapter,
      startVerse: startVerse,
      endVerse: endVerse,
    );
  }

  String _normalizeBook(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

class _ParsedReference {
  const _ParsedReference({
    required this.book,
    required this.chapter,
    required this.startVerse,
    required this.endVerse,
  });

  final String book;
  final int chapter;
  final int startVerse;
  final int endVerse;
}
