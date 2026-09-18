class FavoriteVerse {
  final String id;
  final String translation;
  final String book;
  final int chapter;
  final int verse;
  final String text;
  final DateTime savedAt;

  const FavoriteVerse({
    required this.id,
    required this.translation,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.savedAt,
  });

  /// Deterministic ID for a specific verse in a specific translation.
  static String buildId(
    String translation,
    String book,
    int chapter,
    int verse,
  ) =>
      '${translation}_${book}_${chapter}_$verse';

  factory FavoriteVerse.fromJson(Map<String, dynamic> json) {
    return FavoriteVerse(
      id: json['id'] as String,
      translation: json['translation'] as String,
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
      text: json['text'] as String,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'translation': translation,
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'text': text,
        'savedAt': savedAt.toIso8601String(),
      };
}
