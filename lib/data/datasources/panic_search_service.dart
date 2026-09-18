import '../models/panic_entry.dart';
import 'panic_dataset_service.dart';

/// Retrieval service for panic JSONL entries.
///
/// Score = keyword overlap + emotion match + situation match,
/// then lightly scaled by [PanicEntry.priorityWeight].
class PanicSearchService {
  PanicSearchService({required PanicDatasetService datasetService})
      : _datasetService = datasetService;

  final PanicDatasetService _datasetService;

  // ---------------------------------------------------------------------------
  // Stopwords — filtered out before comparison so they don't inflate scores.
  // ---------------------------------------------------------------------------
  static const _stopwords = <String>{
    'i', 'a', 'an', 'the', 'is', 'am', 'are', 'was', 'were', 'be', 'been',
    'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would',
    'could', 'should', 'may', 'might', 'must', 'can', 'feel', 'feeling',
    'felt', 'just', 'very', 'so', 'too', 'really', 'get', 'got', 'like',
    'me', 'my', 'you', 'your', 'we', 'our', 'they', 'their', 'it', 'its',
    'this', 'that', 'these', 'those', 'and', 'or', 'but', 'not', 'no',
    'from', 'to', 'for', 'in', 'on', 'at', 'by', 'with', 'about', 'of',
    'up', 'out', 'if', 'as', 'into', 'through', 'before', 'after', 'each',
    'more', 'other', 'some', 'than', 'then', 'when', 'where', 'who', 'how',
    'all', 'any', 'both', 'because', 'due', 'seeking', 'biblical', 'guidance',
    'since', 'while', 'during', 'such',
  };

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the [PanicEntry] that best matches [userMessage].
  PanicEntry findBestResponse({
    required String userMessage,
    required List<String> detectedEmotions,
  }) {
    final entries = _datasetService.entries;
    if (entries.isEmpty) throw StateError('Panic dataset is empty.');

    PanicEntry? best;
    double bestScore = -1;

    for (final entry in entries) {
      final score = calculateScore(
        userMessage: userMessage,
        detectedEmotions: detectedEmotions,
        entry: entry,
      );
      if (score > bestScore) {
        bestScore = score;
        best = entry;
      }
    }

    // Fallback: no meaningful overlap — return highest-priority entry.
    if (bestScore == 0) {
      return entries.reduce(
        (a, b) => a.priorityWeight >= b.priorityWeight ? a : b,
      );
    }

    return best!;
  }

  // ---------------------------------------------------------------------------
  // Scoring — public so it can be unit-tested independently
  // ---------------------------------------------------------------------------

  /// Computes score = keyword overlap + emotion match + situation match.
  double calculateScore({
    required String userMessage,
    required List<String> detectedEmotions,
    required PanicEntry entry,
  }) {
    final userTokens = _tokenize(userMessage);
    if (userTokens.isEmpty) return 0;

    double score = 0;
    final detected = detectedEmotions.map((e) => e.toLowerCase()).toSet();

    // Keyword overlap from trigger examples and search text.
    for (final trigger in entry.triggerExamples) {
      score += userTokens.intersection(_tokenize(trigger)).length;
    }
    score += userTokens.intersection(_tokenize(entry.searchText)).length;

    // Emotion match.
    for (final tag in entry.emotionTags) {
      if (detected.contains(tag)) {
        score += 5;
      } else if (userTokens.intersection(_tokenize(tag)).isNotEmpty) {
        score += 2;
      }
    }

    // Situation match.
    for (final tag in entry.situationTags) {
      final overlap = userTokens.intersection(_tokenize(tag)).length;
      if (overlap > 0) {
        score += 3 + overlap;
      }
    }

    // Priority provides a slight preference but should not dominate matches.
    final weighted = score * (0.8 + (entry.priorityWeight * 0.2));
    return weighted;
  }

  // ---------------------------------------------------------------------------
  // Text preprocessing
  // ---------------------------------------------------------------------------

  /// Lowercases [text], strips punctuation, splits on whitespace and removes
  /// short words and stopwords.
  Set<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s]"), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2 && !_stopwords.contains(word))
        .toSet();
  }
}
