import 'package:flutter/services.dart';

import '../../core/utils/jsonl_parser.dart';
import '../models/panic_entry.dart';

/// Loads and caches the panic JSONL dataset used by the panic RAG pipeline.
class PanicDatasetService {
  static const String _assetPath = 'assets/data/panic_responses.jsonl';

  List<PanicEntry>? _entries;

  /// Parses the JSONL asset once and caches all entries in memory.
  Future<void> init() async {
    if (_entries != null) return;

    final rawContent = await rootBundle.loadString(_assetPath);
    final lines = JsonlParser.parse(rawContent);
    _entries = lines.map(PanicEntry.fromJson).toList(growable: false);
  }

  List<PanicEntry> get entries {
    final data = _entries;
    if (data == null) {
      throw StateError(
        'PanicDatasetService is not initialized. Call init() before use.',
      );
    }
    return data;
  }

  int get count => entries.length;
}
