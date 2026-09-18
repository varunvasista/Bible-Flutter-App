import 'dart:convert';

/// Parses a JSONL (JSON Lines) string into a list of decoded objects.
///
/// Each non-empty line must be a valid JSON object. Blank lines are skipped.
/// Throws a [FormatException] if any line is malformed.
class JsonlParser {
  JsonlParser._();

  /// Parses [rawContent] (the full text of a .jsonl file) and returns a list
  /// of [Map<String, dynamic>] — one entry per non-empty line.
  static List<Map<String, dynamic>> parse(String rawContent) {
    final lines = const LineSplitter().convert(rawContent);
    final results = <Map<String, dynamic>>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final decoded = jsonDecode(line);
        if (decoded is Map<String, dynamic>) {
          results.add(decoded);
        } else {
          throw const FormatException('Expected a JSON object on each line.');
        }
      } on FormatException catch (e) {
        throw FormatException('JSONL parse error on line ${i + 1}: $e');
      }
    }

    return results;
  }
}
