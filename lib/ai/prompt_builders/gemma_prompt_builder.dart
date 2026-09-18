import '../../data/models/bible_verse.dart';
import '../../data/models/panic_entry.dart';
import '../../data/models/panic_response.dart';

class GemmaPromptBuilder {
  /// Builds a RAG-style spiritual guidance prompt using API-fetched verses.
  ///
  /// Used by [SpiritualGuidanceService] for the Panic / Guidance screen.
  static String buildGuidancePrompt({
    required String userMessage,
    required String emotion,
    required List<BibleVerse> verses,
  }) {
    final verseReferences = verses.isEmpty
        ? 'None available.'
        : verses.map((v) => v.reference).join(', ');
    final verseText = verses.isEmpty
        ? 'No scripture passages available.'
        : verses.map((v) => '${v.reference}\n"${v.text.trim()}"').join('\n\n');

    return '''
You are a compassionate Christian spiritual guide.

User problem:
"$userMessage"

Detected emotional state: $emotion

Situation:
The user is asking for spiritual support for their present struggle.

Relevant scripture references:
$verseReferences

Relevant scripture text:
$verseText

Based on these scriptures, provide:
1. A warm understanding of their situation (2–3 sentences).
2. Biblical encouragement drawing from the verses above (3–4 sentences).
3. A short prayer (2–3 sentences).

Be concise, warm, and pastoral. Do not invent scripture references not listed above.
'''.trim();
  }

  /// Builds a journal reflection prompt that generates numbered prayer points.
  ///
  /// Used by [JournalReflectionService].
  static String buildJournalPrompt({
    required String journalText,
    required String emotion,
    required List<BibleVerse> verses,
  }) {
    final verseBlock = verses.isEmpty
        ? 'No scripture passages available.'
        : verses
            .map((v) => '${v.reference}\n"${v.text.trim()}"')
            .join('\n\n');

    return '''
You are a Christian prayer guide helping someone reflect on their journal entry.

Journal entry:
"$journalText"

Detected emotional state: $emotion

Relevant Bible verses:
$verseBlock

Generate exactly 3 specific prayer points based on this entry and these scriptures.

Format your response as:
1. ...
2. ...
3. ...

Keep each point concise (1–2 sentences). Ground them in the scriptures above.
'''.trim();
  }

  /// Legacy: rewrite structured JSONL guidance in a warm natural tone.
  ///
  /// Kept for backward-compatible fallback in [GemmaModelService.generateResponse].
  static String buildPanicRewritePrompt({
    required String userMessage,
    required PanicResponse panicResponse,
  }) {
    final c = panicResponse.response;
    final guidance = '''
Understanding the Situation:
${c.understandingUserQuery}

Biblical Explanation:
${c.biblicalExplanation}

Biblical Story Example:
${c.biblicalStoryExample}

Recommended Verses:
${c.recommendedVerses.join(', ')}

Short Prayer:
${c.shortPrayer}
''';

    return '''
You are a compassionate Christian spiritual guide.

Rewrite the following structured guidance in a warm and natural way.

User message:
$userMessage

Guidance:
$guidance

Respond in a supportive and pastoral tone.
Keep it concise (120-220 words), include 1 short prayer sentence, and do not invent any new facts.
''';
  }

  /// Builds the panic RAG prompt using a retrieved [PanicEntry].
  ///
  /// If [fetchedVerses] are provided (resolved from the local Bible dataset), their
  /// full text is included in the prompt; otherwise only the reference strings
  /// from the dataset entry are listed.
  static String buildPanicGuidancePrompt({
    required String userMessage,
    required String detectedEmotion,
    required PanicEntry entry,
    List<String> detectedEmotions = const [],
    List<BibleVerse> fetchedVerses = const [],
  }) {
    final String verseReferences;
    final String verseText;
    if (fetchedVerses.isNotEmpty) {
      verseReferences = fetchedVerses.map((v) => v.reference).join(', ');
      verseText = fetchedVerses
          .map((v) => '${v.reference}\n"${v.text.trim()}"')
          .join('\n\n');
    } else if (entry.response.recommendedVerses.isEmpty) {
      verseReferences = 'None provided in dataset entry.';
      verseText = 'No scripture text available.';
    } else {
      verseReferences = entry.response.recommendedVerses.join(', ');
      verseText = 'Scripture text unavailable from API; use references only.';
    }

    final emotionTags = entry.emotionTags.isEmpty
      ? detectedEmotion
      : entry.emotionTags.join(', ');
    final detectedEmotionList = detectedEmotions.isEmpty
      ? detectedEmotion
      : detectedEmotions.join(', ');

    return '''
You are a compassionate Christian spiritual guide.

  A user is struggling with the following situation.

  User message:
  $userMessage

  Detected emotion:
  $detectedEmotionList

  Emotion tags:
  $emotionTags

Situation tags:
${entry.situationTags.join(', ')}

Biblical explanation:
${entry.response.biblicalExplanation}

Story example:
${entry.response.biblicalStoryExample}

Relevant scripture references:
$verseReferences

Relevant scripture text:
$verseText

Write a warm pastoral response that:
- understands the user's struggle
- explains biblical encouragement
- references scripture naturally
- ends with a short prayer

Do NOT return sections or headings.
Write one natural conversational response.
Keep it concise, gentle, and practical.
Do not invent scripture references beyond the provided list.
'''.trim();
  }
}
