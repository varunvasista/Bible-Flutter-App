import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../ai/services/emotion_detection_service.dart';
import '../../../ai/services/gemma_model_service.dart';
import '../../journal/models/journal_entry.dart';
import '../../journal/services/verse_suggestion_service.dart';

/// Generates daily prayer points from journal + Kyrie context.
///
/// Pipeline:
///   context text -> emotion detection -> relevant verses -> Gemma generation
///   -> parsed prayer points.
class PrayerPointService {
  PrayerPointService({
    required EmotionDetectionService emotionDetection,
    required GemmaModelService modelService,
    required VerseSuggestionService verseSuggestionService,
  })  : _emotionDetection = emotionDetection,
        _modelService = modelService,
        _verseSuggestionService = verseSuggestionService;

  static const _dateKey = 'daily_prayer_points_date';
  static const _pointsKey = 'daily_prayer_points_payload';

  final EmotionDetectionService _emotionDetection;
  final GemmaModelService _modelService;
  final VerseSuggestionService _verseSuggestionService;

  Future<List<String>> getPrayerPointsForToday({
    JournalEntry? latestJournal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateOnly(DateTime.now());

    final cachedDate = prefs.getString(_dateKey);
    final cachedPayload = prefs.getString(_pointsKey);
    if (cachedDate == today && cachedPayload != null && cachedPayload.isNotEmpty) {
      try {
        final list = List<String>.from(jsonDecode(cachedPayload) as List);
        final cleaned = list.where((p) => !_isPlaceholderOutput(p)).toList();
        if (cleaned.isNotEmpty) {
          return cleaned.take(3).toList(growable: false);
        }
      } catch (_) {
        // Re-generate when cached payload is malformed.
      }
    }

    final contextChunks = <String>[];
    if (latestJournal != null && latestJournal.text.trim().isNotEmpty) {
      contextChunks.add('Journal: ${latestJournal.text.trim()}');
    }

    final mergedText = contextChunks.join('\n\n');
    final detected = mergedText.trim().isEmpty
        ? <String>['peace']
        : _emotionDetection.detectEmotions(mergedText);

    final normalizedEmotions = detected
        .map((e) => e.toLowerCase() == 'reflection' ? 'peace' : e)
        .toSet()
        .toList(growable: false);

    final verses = <String>[];
    for (final emotion in normalizedEmotions.take(3)) {
      try {
        final verse = await _verseSuggestionService.getVerseForEmotion(emotion);
        verses.add('${verse.reference}: ${verse.cleanText}');
      } catch (_) {
        // Continue with remaining verses.
      }
    }

    final prompt = _buildPrayerPrompt(
      context: mergedText,
      emotions: normalizedEmotions,
      verses: verses,
    );

    final generated = await _modelService.generateResponse(prompt);
    if (_isPlaceholderOutput(generated)) {
      throw Exception('Gemma produced placeholder output for prayer points.');
    }
    final points = _parsePrayerPoints(generated);
    if (points.isEmpty) {
      throw Exception('Gemma output did not contain prayer points.');
    }

    final finalPoints = points.take(3).toList(growable: false);
    await prefs.setString(_dateKey, today);
    await prefs.setString(_pointsKey, jsonEncode(finalPoints));
    return finalPoints;
  }

  String _buildPrayerPrompt({
    required String context,
    required List<String> emotions,
    required List<String> verses,
  }) {
    final emotionBlock = emotions.isEmpty ? 'peace' : emotions.join(', ');
    final contextBlock = context.trim().isEmpty
        ? 'No journal or Kyrie request was provided today.'
        : context;
    final verseBlock = verses.isEmpty ? 'No verse context available.' : verses.join('\n');

    return '''
You are a compassionate Christian prayer guide.

User context for today:
$contextBlock

Detected emotions:
$emotionBlock

Relevant verses:
$verseBlock

Generate exactly 3 short prayer points for today.

Rules:
- Keep each point to 1-2 sentences.
- Be pastoral, warm, and practical.
- Ground encouragement in the provided verse context.
- Do not add section titles.
- Return only the prayer points as numbered lines.
'''.trim();
  }

  List<String> _parsePrayerPoints(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final points = <String>[];
    for (final line in lines) {
      final cleaned = line
          .replaceFirst(RegExp(r'^\d+[\).]\s*'), '')
          .replaceFirst(RegExp(r'^[-*]\s*'), '')
          .trim();
      if (cleaned.isNotEmpty && !_isPlaceholderOutput(cleaned)) {
        points.add(cleaned);
      }
      if (points.length >= 3) break;
    }

    return points;
  }

  bool _isPlaceholderOutput(String text) {
    final lower = text.toLowerCase();
    return lower.contains('gemma stub') ||
        lower.contains('llama.cpp submodule') ||
        lower.contains('developer message') ||
        lower.contains('debug');
  }

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
