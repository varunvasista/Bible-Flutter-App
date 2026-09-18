import '../../../ai/services/emotion_detection_service.dart';
import '../../../ai/services/gemma_model_service.dart';
import '../../../ai/prompt_builders/gemma_prompt_builder.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/local_bible_service.dart';
import '../../../data/models/bible_verse.dart';
import '../../../data/models/panic_entry.dart';
import '../../../data/datasources/panic_search_service.dart';

class PanicGuidanceResult {
  final String emotion;
  final PanicEntry entry;
  final String responseText;
  /// Verse texts resolved from the bundled local NLT dataset.
  final List<BibleVerse> fetchedVerses;

  const PanicGuidanceResult({
    required this.emotion,
    required this.entry,
    required this.responseText,
    this.fetchedVerses = const [],
  });
}

/// End-to-end panic RAG pipeline service.
///
/// Flow:
///   user message -> emotion detection -> dataset retrieval -> verse fetch
///   (via [LocalBibleService]) -> prompt builder -> Gemma model inference
///   -> generated response.
class PanicGuidanceService {
  PanicGuidanceService({
    required EmotionDetectionService emotionDetection,
    required PanicSearchService searchService,
    required GemmaModelService modelService,
    required LocalBibleService localBible,
  })  : _emotionDetection = emotionDetection,
        _searchService = searchService,
        _modelService = modelService,
        _localBible = localBible;

  final EmotionDetectionService _emotionDetection;
  final PanicSearchService _searchService;
  final GemmaModelService _modelService;
  final LocalBibleService _localBible;

  Future<PanicGuidanceResult> handleUserMessage(String message) async {
    if (!_modelService.isInitialized) {
      throw Exception('AI is still initializing. Please try again in a moment.');
    }

    final detectedEmotions = _emotionDetection.detectEmotions(message);
    final primaryEmotion = detectedEmotions.first;

    final entry = _searchService.findBestResponse(
      userMessage: message,
      detectedEmotions: detectedEmotions,
    );

    // Fetch actual verse text for up to 2 recommended verses from the local dataset.
    final fetchedVerses = <BibleVerse>[];
    for (final ref in entry.response.recommendedVerses.take(2)) {
      try {
        fetchedVerses.add(_localBible.getPassage(ref));
      } catch (_) {
        // Skip verses that fail to resolve; fallback references still in prompt.
      }
    }

    final prompt = GemmaPromptBuilder.buildPanicGuidancePrompt(
      userMessage: message,
      detectedEmotion: primaryEmotion,
      detectedEmotions: detectedEmotions,
      entry: entry,
      fetchedVerses: fetchedVerses,
    );
    debugPrint('Gemma generating response...');
    debugPrint('Prompt length: ${prompt.length}');

    final generated = await _modelService.generateResponse(prompt);
    if (generated.trim().isEmpty) {
      throw Exception('Gemma returned empty panic guidance output.');
    }

    debugPrint('PanicGuidanceService: using Gemma-generated response.');
    return PanicGuidanceResult(
      emotion: primaryEmotion,
      entry: entry,
      responseText: generated.trim(),
      fetchedVerses: fetchedVerses,
    );
  }
}
