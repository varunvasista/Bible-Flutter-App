import 'hymn_section.dart';

class Hymn {
  final String id;
  final int number;
  final String title;
  final List<HymnSection> sections;

  Hymn({
    required this.id,
    required this.number,
    required this.title,
    required this.sections,
  });

  factory Hymn.fromJson(Map<String, dynamic> json) {
    return Hymn(
      id: json['id'],
      number: json['number'],
      title: json['title'],
      sections: (json['sections'] as List)
          .map((section) => HymnSection.fromJson(section))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }
}
