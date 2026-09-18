import '../../data/models/bible_verse.dart';
import 'emotion_verses_repository.dart';
import 'emotion_detection_service.dart';
import 'gemma_model_service.dart';
import '../prompt_builders/gemma_prompt_builder.dart';
import '../../core/services/local_bible_service.dart';

/// Result returned by [SpiritualGuidanceService.generateGuidance].
class GuidanceResult {
  final String emotion;
  final List<BibleVerse> verses;
  final String guidance;

  /// Whether the guidance text was produced by the local Gemma model.
  /// False means a template-based fallback was used.
  final bool usedAiModel;

  const GuidanceResult({
    required this.emotion,
    required this.verses,
    required this.guidance,
    this.usedAiModel = true,
  });
}

///   user message
///   → EmotionDetectionService
///   → emotion → verse references (emotion_verses.json)
///   → LocalBibleService
///   → GemmaPromptBuilder.buildGuidancePrompt
///   → GemmaModelService
///   → GuidanceResult
class SpiritualGuidanceService {
  SpiritualGuidanceService({
    required EmotionDetectionService emotionDetection,
    required LocalBibleService localBible,
    required GemmaModelService modelService,
    required EmotionVersesRepository emotionVerses,
  })  : _emotionDetection = emotionDetection,
        _localBible = localBible,
        _modelService = modelService,
        _emotionVerses = emotionVerses;

  final EmotionDetectionService _emotionDetection;
  final LocalBibleService _localBible;
  final GemmaModelService _modelService;
  final EmotionVersesRepository _emotionVerses;

  /// Runs the full RAG pipeline for [userMessage].
  Future<GuidanceResult> generateGuidance(String userMessage) async {
    // 1. Detect primary emotion
    final emotions = _emotionDetection.detectEmotions(userMessage);
    final primaryEmotion = emotions.first;

    // 2. Get verse references mapped to the detected emotion
    final references = _emotionVerses.versesFor(primaryEmotion);

    // 3. Fetch top 2 verses from the bundled local NLT dataset.
    final verses = await _fetchVerses(references.take(2).toList());

    // 4. Build RAG prompt
    final prompt = GemmaPromptBuilder.buildGuidancePrompt(
      userMessage: userMessage,
      emotion: primaryEmotion,
      verses: verses,
    );

    // 5. Generate with Gemma only.
    final guidance = await _modelService.generateFromPrompt(prompt);
    if (guidance.trim().isEmpty) {
      throw Exception('Gemma returned empty guidance output.');
    }

    return GuidanceResult(
      emotion: primaryEmotion,
      verses: verses,
      guidance: guidance.trim(),
      usedAiModel: true,
    );
  }

  Future<List<BibleVerse>> _fetchVerses(List<String> references) async {
    final verses = <BibleVerse>[];
    for (final ref in references) {
      try {
        verses.add(_localBible.getPassage(ref));
      } catch (_) {
        // Skip verses that fail; others may still succeed.
      }
    }
    return verses;
  }
}

