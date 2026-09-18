class BibleVerse {
  /// Human-readable reference such as "Philippians 4:6-7".
  final String reference;
  final int verse;
  final String text;
  final String? translation;
  final String? book;
  final int? chapter;

  const BibleVerse({
    required this.verse,
    required this.text,
    this.reference = '',
    this.translation,
    this.book,
    this.chapter,
  });

  /// Creates a passage verse from a resolved reference and text payload.
  factory BibleVerse.fromApiPassage({
    required String reference,
    required String text,
  }) =>
      BibleVerse(verse: 0, text: text, reference: reference);

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    final book      = json['book'] as String?;
    final chapter   = (json['chapter'] as num?)?.toInt();
    final verseNum  = (json['verse'] as num?)?.toInt() ?? 0;
    final rawRef    = json['reference'] as String?;

    // Compose a fallback reference from structural fields when the stored
    // reference field is empty or absent (e.g. verses loaded from local JSON).
    String reference = rawRef ?? '';
    if (reference.isEmpty && book != null && chapter != null && verseNum > 0) {
      reference = '$book $chapter:$verseNum';
    }

    return BibleVerse(
      verse:       verseNum,
      text:        json['text'] as String? ?? '',
      reference:   reference,
      book:        book,
      chapter:     chapter,
      translation: json['translation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'verse': verse,
        'text': text,
        'reference': reference,
        if (translation != null) 'translation': translation,
        if (book != null) 'book': book,
        if (chapter != null) 'chapter': chapter,
      };

  @override
  String toString() =>
      'BibleVerse(reference: $reference, verse: $verse, text: ${text.length > 60 ? '${text.substring(0, 60)}…' : text})';
}
