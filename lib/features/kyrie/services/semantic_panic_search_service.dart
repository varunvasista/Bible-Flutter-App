import 'dart:math' show max;

import '../../../data/models/panic_response.dart';
import '../../../data/repositories/panic_response_repository.dart';
import 'text_processing_service.dart';

/// Improved offline retrieval service using a multi-signal semantic scoring
/// algorithm.
///
/// Compared with the original [PanicSearchService]:
///
///   1. **Text processing** is delegated to [TextProcessingService], which
///      applies canonical normalisation (anxious → anxiety) and lightweight
///      stemming before comparison.
///
///   2. **Trigger-example scoring** distinguishes high-coverage matches
///      (+5) from partial matches (proportional +3 scale).
///
///   3. **TF-style search-text bonus** rewards entries whose `search_text`
///      has proportionally more overlap with the query.
///
///   4. **[findTopResponses]** returns a ranked list of candidates when the
///      caller needs to show alternatives.
///
/// Scoring summary per entry (before × priority_weight):
///   • trigger_examples near/full match    → up to +5 per trigger
///   • trigger_examples partial match      → up to +3× overlap_ratio per trigger
///   • emotion_tags match (exact or stem)  → +3 per tag
///   • situation_tags match                → +2 per tag
///   • search_text word overlap            → +1 per matched word
///   • search_text TF bonus               → +2 × (overlap / total_words)
class SemanticPanicSearchService {
  SemanticPanicSearchService({required PanicResponseRepository repository})
      : _repo = repository;

  final PanicResponseRepository _repo;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns the single [PanicResponse] that best matches [userMessage].
  ///
  /// Falls back to the highest-priority entry when the query yields no matches.
  PanicResponse findBestResponse(String userMessage) {
    final ranked = findTopResponses(userMessage, 1);
    return ranked.first;
  }

  /// Returns up to [limit] entries ranked by descending semantic score.
  List<PanicResponse> findTopResponses(String userMessage, int limit) {
    final entries = _repo.getAllPanicResponses();
    if (entries.isEmpty) throw StateError('Panic dataset is empty.');

    final queryTokens = TextProcessingService.process(userMessage);
    final queryStems = queryTokens.map(TextProcessingService.stem).toSet();

    // Score every entry.
    final scored = entries.map((e) {
      final score = _scoreEntry(queryTokens, queryStems, e);
      return (entry: e, score: score);
    }).toList();

    // Sort descending.
    scored.sort((a, b) => b.score.compareTo(a.score));

    // If top score is 0, fall back to priority-ranked entries.
    if (scored.first.score == 0) {
      final byPriority = List.of(entries)
        ..sort((a, b) => b.priorityWeight.compareTo(a.priorityWeight));
      return byPriority.take(limit).toList();
    }

    return scored.take(limit).map((r) => r.entry).toList();
  }

  /// Exposes the score for unit-testing and debugging purposes.
  double scoreEntry(String userMessage, PanicResponse entry) {
    final q = TextProcessingService.process(userMessage);
    final qs = q.map(TextProcessingService.stem).toSet();
    return _scoreEntry(q, qs, entry);
  }

  // ── Scoring ───────────────────────────────────────────────────────────────

  double _scoreEntry(
    Set<String> queryTokens,
    Set<String> queryStems,
    PanicResponse entry,
  ) {
    if (queryTokens.isEmpty) return 0;

    double score = 0;

    // ── 1. Trigger examples ─────────────────────────────────────────────────
    for (final trigger in entry.triggerExamples) {
      final trigTokens = TextProcessingService.process(trigger);
      final trigStems = trigTokens.map(TextProcessingService.stem).toSet();

      final exactOverlap = queryTokens.intersection(trigTokens).length;
      final stemOverlap = queryStems.intersection(trigStems).length;
      final overlap = max(exactOverlap, stemOverlap);

      if (overlap == 0) continue;

      final coverageOfTrigger =
          trigTokens.isEmpty ? 0.0 : overlap / trigTokens.length;
      final coverageOfQuery =
          queryTokens.isEmpty ? 0.0 : overlap / queryTokens.length;
      // Use the higher coverage ratio.
      final coverage = max(coverageOfTrigger, coverageOfQuery);

      if (coverage >= 0.5) {
        // Strong hit: most of the trigger (or query) is covered.
        score += 5;
      } else {
        // Partial hit: scale proportionally up to +3.
        score += 3 * coverage;
      }
    }

    // ── 2. Emotion tags (+3 each) ───────────────────────────────────────────
    for (final tag in entry.emotionTags) {
      final tagTokens = TextProcessingService.process(tag);
      final tagStems = tagTokens.map(TextProcessingService.stem).toSet();

      if (queryTokens.intersection(tagTokens).isNotEmpty ||
          queryStems.intersection(tagStems).isNotEmpty) {
        score += 3;
      }
    }

    // ── 3. Situation tags (+2 each) ─────────────────────────────────────────
    for (final tag in entry.situationTags) {
      final tagTokens = TextProcessingService.process(tag);
      final tagStems = tagTokens.map(TextProcessingService.stem).toSet();

      if (queryTokens.intersection(tagTokens).isNotEmpty ||
          queryStems.intersection(tagStems).isNotEmpty) {
        score += 2;
      }
    }

    // ── 4. Search text: overlap + TF bonus ─────────────────────────────────
    final stTokens = TextProcessingService.process(entry.searchText);
    final stStems = stTokens.map(TextProcessingService.stem).toSet();

    final stExact = queryTokens.intersection(stTokens).length;
    final stStem = queryStems.intersection(stStems).length;
    final stOverlap = max(stExact, stStem);

    if (stTokens.isNotEmpty && stOverlap > 0) {
      final tf = stOverlap / stTokens.length;
      score += stOverlap * 1.0 + tf * 2.0;
    }

    return score * entry.priorityWeight;
  }
}
