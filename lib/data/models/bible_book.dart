import 'bible_chapter.dart';
import 'bible_verse.dart';

class BibleBook {
  final String name;
  final List<BibleChapter> chapters;

  const BibleBook({
    required this.name,
    required this.chapters,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    final rawChapters = json['chapters'] as List<dynamic>;
    return BibleBook(
      name: json['name'] as String,
      chapters: rawChapters
          .map((c) => BibleChapter.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Returns a chapter by its 1-based number, or null if not found.
  BibleChapter? getChapter(int chapterNumber) {
    try {
      return chapters.firstWhere((c) => c.chapter == chapterNumber);
    } catch (_) {
      return null;
    }
  }

  /// Returns a specific verse directly, or null if not found.
  BibleVerse? getVerse(int chapterNumber, int verseNumber) {
    return getChapter(chapterNumber)?.getVerse(verseNumber);
  }
}
