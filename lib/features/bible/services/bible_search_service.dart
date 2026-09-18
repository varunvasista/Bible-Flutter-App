import '../../../data/models/bible_verse.dart';
import '../../../data/repositories/bible_repository.dart';

/// Full-text Bible search across all currently loaded translations.
class BibleSearchService {
  BibleSearchService({required BibleRepository repository})
      : _repository = repository;

  final BibleRepository _repository;

  /// Searches verse text using a simple case-insensitive substring match.
  ///
  /// Returns [BibleVerse] records that include translation/book/chapter metadata
  /// so the caller can navigate directly to the reference.
  List<BibleVerse> searchVerses(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];

    final results = <BibleVerse>[];
    for (final translation in _repository.getLoadedTranslations()) {
      final testaments = _repository.getTestaments(translation);
      for (final testament in testaments) {
        for (final book in testament.books) {
          for (final chapter in book.chapters) {
            for (final verse in chapter.verses) {
              if (verse.text.toLowerCase().contains(needle)) {
                results.add(
                  BibleVerse(
                    translation: translation,
                    book: book.name,
                    chapter: chapter.chapter,
                    verse: verse.verse,
                    text: verse.text,
                  ),
                );
              }
            }
          }
        }
      }
    }

    return results;
  }
}
