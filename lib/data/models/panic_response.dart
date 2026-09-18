class PanicResponseContent {
  final String understandingUserQuery;
  final String biblicalExplanation;
  final String biblicalStoryExample;
  final List<String> recommendedVerses;
  final String shortPrayer;

  const PanicResponseContent({
    required this.understandingUserQuery,
    required this.biblicalExplanation,
    required this.biblicalStoryExample,
    required this.recommendedVerses,
    required this.shortPrayer,
  });

  factory PanicResponseContent.fromJson(Map<String, dynamic> json) {
    final rawVerses = json['recommended_verses'] as List<dynamic>;
    return PanicResponseContent(
      understandingUserQuery: json['understanding_user_query'] as String,
      biblicalExplanation: json['biblical_explanation'] as String,
      biblicalStoryExample: json['biblical_story_example'] as String,
      recommendedVerses: rawVerses.map((v) => v as String).toList(),
      shortPrayer: json['short_prayer'] as String,
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

class PanicResponse {
  final String id;
  final List<String> emotionTags;
  final List<String> situationTags;
  final List<String> triggerExamples;
  final String searchText;
  final double priorityWeight;
  final PanicResponseContent response;

  const PanicResponse({
    required this.id,
    required this.emotionTags,
    required this.situationTags,
    required this.triggerExamples,
    required this.searchText,
    required this.priorityWeight,
    required this.response,
  });

  factory PanicResponse.fromJson(Map<String, dynamic> json) {
    final rawEmotions = json['emotion_tags'] as List<dynamic>;
    final rawSituations = json['situation_tags'] as List<dynamic>;
    final rawTriggers = json['trigger_examples'] as List<dynamic>;

    return PanicResponse(
      id: json['id'] as String,
      emotionTags: rawEmotions.map((e) => e as String).toList(),
      situationTags: rawSituations.map((s) => s as String).toList(),
      triggerExamples: rawTriggers.map((t) => t as String).toList(),
      searchText: json['search_text'] as String,
      priorityWeight: (json['priority_weight'] as num).toDouble(),
      response: PanicResponseContent.fromJson(
        json['response'] as Map<String, dynamic>,
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
