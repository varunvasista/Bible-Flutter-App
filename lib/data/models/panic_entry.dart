class PanicEntryResponse {
  final String understandingUserQuery;
  final String biblicalExplanation;
  final String biblicalStoryExample;
  final List<String> recommendedVerses;
  final String shortPrayer;

  const PanicEntryResponse({
    required this.understandingUserQuery,
    required this.biblicalExplanation,
    required this.biblicalStoryExample,
    required this.recommendedVerses,
    required this.shortPrayer,
  });

  factory PanicEntryResponse.fromJson(Map<String, dynamic> json) {
    final rawVerses = (json['recommended_verses'] as List<dynamic>? ?? const []);
    return PanicEntryResponse(
      understandingUserQuery: (json['understanding_user_query'] as String? ?? '').trim(),
      biblicalExplanation: (json['biblical_explanation'] as String? ?? '').trim(),
      biblicalStoryExample: (json['biblical_story_example'] as String? ?? '').trim(),
      recommendedVerses: rawVerses.map((v) => (v as String).trim()).where((v) => v.isNotEmpty).toList(),
      shortPrayer: (json['short_prayer'] as String? ?? '').trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'understanding_user_query': understandingUserQuery,
        'biblical_explanation': biblicalExplanation,
        'biblical_story_example': biblicalStoryExample,
        'recommended_verses': recommendedVerses,
        'short_prayer': shortPrayer,
      };
}

class PanicEntry {
  final String id;
  final List<String> emotionTags;
  final List<String> situationTags;
  final List<String> triggerExamples;
  final String searchText;
  final double priorityWeight;
  final PanicEntryResponse response;

  const PanicEntry({
    required this.id,
    required this.emotionTags,
    required this.situationTags,
    required this.triggerExamples,
    required this.searchText,
    required this.priorityWeight,
    required this.response,
  });

  factory PanicEntry.fromJson(Map<String, dynamic> json) {
    final rawEmotionTags = json['emotion_tags'] as List<dynamic>? ?? const [];
    final rawSituationTags = json['situation_tags'] as List<dynamic>? ?? const [];
    final rawTriggerExamples = json['trigger_examples'] as List<dynamic>? ?? const [];

    return PanicEntry(
      id: (json['id'] as String? ?? '').trim(),
      emotionTags: rawEmotionTags.map((e) => (e as String).trim().toLowerCase()).where((e) => e.isNotEmpty).toList(),
      situationTags: rawSituationTags.map((s) => (s as String).trim().toLowerCase()).where((s) => s.isNotEmpty).toList(),
      triggerExamples: rawTriggerExamples.map((t) => (t as String).trim()).where((t) => t.isNotEmpty).toList(),
      searchText: (json['search_text'] as String? ?? '').trim(),
      priorityWeight: (json['priority_weight'] as num? ?? 1.0).toDouble(),
      response: PanicEntryResponse.fromJson(
        json['response'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'emotion_tags': emotionTags,
        'situation_tags': situationTags,
        'trigger_examples': triggerExamples,
        'search_text': searchText,
        'priority_weight': priorityWeight,
        'response': response.toJson(),
      };
}
