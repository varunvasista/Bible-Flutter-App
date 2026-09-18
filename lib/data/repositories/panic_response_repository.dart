import '../models/panic_response.dart';
import '../datasources/panic_dataset_loader.dart';

/// In-memory repository for the spiritual-guidance panic-response dataset.
///
/// Call [init] once (e.g. in main.dart before runApp) to parse and cache all
/// [PanicResponse] entries. All lookup methods are synchronous after that.
class PanicResponseRepository {
  PanicResponseRepository({PanicDatasetLoader? loader})
      : _loader = loader ?? PanicDatasetLoader();

  final PanicDatasetLoader _loader;
  List<PanicResponse>? _responses;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Parses the bundled JSONL asset and caches all entries.
  /// Safe to call multiple times; subsequent calls are no-ops.
  Future<void> init() async {
    _responses ??= await _loader.load();
  }

  List<PanicResponse> get _data {
    if (_responses == null) {
      throw StateError(
        'PanicResponseRepository has not been initialised. '
        'Await PanicResponseRepository.init() before accessing data.',
      );
    }
    return _responses!;
  }

  // ---------------------------------------------------------------------------
  // Accessors
  // ---------------------------------------------------------------------------

  /// Returns all loaded [PanicResponse] entries (unmodifiable).
  List<PanicResponse> getAllPanicResponses() => List.unmodifiable(_data);

  /// Returns a single entry by its unique [id], or null if not found.
  PanicResponse? getById(String id) {
    try {
      return _data.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns all entries whose [PanicResponse.emotionTags] contain every
  /// emotion in [emotions] (case-insensitive).
  List<PanicResponse> getByEmotions(List<String> emotions) {
    final normalised = emotions.map((e) => e.toLowerCase()).toSet();
    return _data.where((r) {
      final tags = r.emotionTags.map((e) => e.toLowerCase()).toSet();
      return normalised.every(tags.contains);
    }).toList();
  }

  /// Returns all entries whose [PanicResponse.situationTags] contain at least
  /// one of the provided [situations] (case-insensitive).
  List<PanicResponse> getBySituation(List<String> situations) {
    final normalised = situations.map((s) => s.toLowerCase()).toSet();
    return _data.where((r) {
      return r.situationTags
          .any((s) => normalised.contains(s.toLowerCase()));
    }).toList();
  }

  /// Simple keyword-search over [PanicResponse.searchText] and
  /// [PanicResponse.triggerExamples].
  ///
  /// Returns entries sorted by [PanicResponse.priorityWeight] descending.
  List<PanicResponse> search(String query) {
    final lower = query.toLowerCase();
    final matches = _data.where((r) {
      if (r.searchText.toLowerCase().contains(lower)) return true;
      return r.triggerExamples.any((t) => t.toLowerCase().contains(lower));
    }).toList();

    matches.sort((a, b) => b.priorityWeight.compareTo(a.priorityWeight));
    return matches;
  }

  /// Total number of loaded entries.
  int get count => _data.length;
}
