import '../../../data/models/bible_verse.dart';
import '../../../data/repositories/bible_repository.dart';

/// Lightweight chapter-level cache to avoid repeated verse list rebuilds.
class BibleCacheService {
  BibleCacheService({required BibleRepository repository})
      : _repository = repository;

  final BibleRepository _repository;
  final Map<String, List<BibleVerse>> _chapterCache = {};

  String _key(String t, String b, int c) => '${t.toUpperCase()}|$b|$c';

  List<BibleVerse> getChapterVerses(
    String translation,
    String book,
    int chapter,
  ) {
    final k = _key(translation, book, chapter);
    final cached = _chapterCache[k];
    if (cached != null) return cached;

    final verses = _repository.getVerses(translation, book, chapter);
    final copy = List<BibleVerse>.unmodifiable(verses);
    _chapterCache[k] = copy;
    return copy;
  }

  void prefetchAdjacentChapters(
    String translation,
    String book,
    int chapter,
  ) {
    final chapterNumbers = _repository.getChapterNumbers(translation, book);
    final currentIndex = chapterNumbers.indexOf(chapter);
    if (currentIndex < 0) return;

    if (currentIndex > 0) {
      getChapterVerses(translation, book, chapterNumbers[currentIndex - 1]);
    }
    if (currentIndex < chapterNumbers.length - 1) {
      getChapterVerses(translation, book, chapterNumbers[currentIndex + 1]);
    }
  }

  void clearTranslation(String translation) {
    final prefix = '${translation.toUpperCase()}|';
    _chapterCache.removeWhere((key, _) => key.startsWith(prefix));
  }

  void clearAll() {
    _chapterCache.clear();
  }
}
