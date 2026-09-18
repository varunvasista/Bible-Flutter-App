import 'bible_verse.dart';

class BibleChapter {
  final int chapter;
  final List<BibleVerse> verses;

  const BibleChapter({
    required this.chapter,
    required this.verses,
  });

  factory BibleChapter.fromJson(Map<String, dynamic> json) {
    final rawVerses = json['verses'] as List<dynamic>;
    return BibleChapter(
      chapter: json['chapter'] as int,
      verses: rawVerses
          .map((v) => BibleVerse.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Returns a specific verse by number, or null if not found.
  BibleVerse? getVerse(int verseNumber) {
    try {
      return verses.firstWhere((v) => v.verse == verseNumber);
    } catch (_) {
      return null;
    }
  }
}
