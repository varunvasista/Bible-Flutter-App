import 'package:flutter/services.dart';

import '../../core/utils/jsonl_parser.dart';
import '../models/panic_response.dart';

/// Loads and parses the panic-response JSONL asset from the app bundle.
///
/// The asset at [_assetPath] is a JSON Lines file where every line is an
/// independent [PanicResponse] JSON object.
class PanicDatasetLoader {
  static const String _assetPath = 'assets/panic/panic_responses.jsonl';

  /// Reads the bundled JSONL file and returns a list of [PanicResponse]s.
  ///
  /// Parsing is done line-by-line via [JsonlParser]. Call once at startup
  /// and cache the result inside [PanicResponseRepository].
  Future<List<PanicResponse>> load() async {
    final rawContent = await rootBundle.loadString(_assetPath);
    final jsonLines = JsonlParser.parse(rawContent);
    return jsonLines.map(PanicResponse.fromJson).toList();
  }
}
