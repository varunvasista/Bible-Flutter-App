class HymnSection {
  final String id;
  final String type;
  final int? verseNumber;
  final String lyrics;

  HymnSection({
    required this.id,
    required this.type,
    this.verseNumber,
    required this.lyrics,
  });

  factory HymnSection.fromJson(Map<String, dynamic> json) {
    return HymnSection(
      id: json['id'],
      type: json['type'],
      verseNumber: json['verseNumber'],
      lyrics: json['lyrics'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'verseNumber': verseNumber,
      'lyrics': lyrics,
    };
  }
}
