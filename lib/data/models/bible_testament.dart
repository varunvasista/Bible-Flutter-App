import 'bible_book.dart';
import 'bible_chapter.dart';
import 'bible_verse.dart';

class BibleTestament {
  final String name;
  final List<BibleBook> books;

  const BibleTestament({
    required this.name,
    required this.books,
  });

  factory BibleTestament.fromJson(Map<String, dynamic> json) {
    final rawBooks = json['books'] as List<dynamic>;
    return BibleTestament(
      name: json['name'] as String,
      books: rawBooks
          .map((b) => BibleBook.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Finds a book by name (case-insensitive), or null if not found.
  BibleBook? getBook(String bookName) {
    try {
      return books.firstWhere(
        (b) => b.name.toLowerCase() == bookName.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  BibleChapter? getChapter(String bookName, int chapterNumber) {
    return getBook(bookName)?.getChapter(chapterNumber);
  }

  BibleVerse? getVerse(String bookName, int chapterNumber, int verseNumber) {
    return getBook(bookName)?.getVerse(chapterNumber, verseNumber);
  }
}

/// Top-level wrapper that includes the translation label and all testaments.
class Bible {
  final String translation;
  final List<BibleTestament> testaments;

  const Bible({
    required this.translation,
    required this.testaments,
  });

  factory Bible.fromJson(Map<String, dynamic> json) {
    final rawTestaments = json['testaments'] as List<dynamic>;
    return Bible(
      translation: json['translation'] as String,
      testaments: rawTestaments
          .map((t) => BibleTestament.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Searches all testaments for a book by name.
  BibleBook? getBook(String bookName) {
    for (final testament in testaments) {
      final book = testament.getBook(bookName);
      if (book != null) return book;
    }
    return null;
  }

  BibleChapter? getChapter(String bookName, int chapterNumber) {
    return getBook(bookName)?.getChapter(chapterNumber);
  }

  BibleVerse? getVerse(String bookName, int chapterNumber, int verseNumber) {
    return getBook(bookName)?.getVerse(chapterNumber, verseNumber);
  }
}
