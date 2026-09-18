class JournalEntry {
  JournalEntry({
    required this.id,
    required this.dateKey,
    required this.text,
    required this.detectedEmotions,
    required this.createdAt,
  });

  /// Unique identifier — milliseconds since epoch as a string.
  final String id;

  /// Calendar date key in ISO format, e.g. '2026-03-13'.
  final String dateKey;

  final String text;

  /// Emotion labels detected from [text], e.g. ['anxiety', 'loneliness'].
  final List<String> detectedEmotions;

  final DateTime createdAt;

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        dateKey: json['dateKey'] as String,
        text: json['text'] as String,
        detectedEmotions: List<String>.from(json['detectedEmotions'] as List),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateKey': dateKey,
        'text': text,
        'detectedEmotions': detectedEmotions,
        'createdAt': createdAt.toIso8601String(),
      };
}
