import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/bible_testament.dart';

/// Loads and parses the Bible JSON asset from the app bundle.
///
/// The asset at [_assetPath] must follow the structure:
/// ```json
/// {
///   "translation": "KJV",
///   "testaments": [ ... ]
/// }
/// ```
class BibleLoaderService {
  static const String _assetPath = 'assets/bible/kjv.json';

  /// Reads the bundled KJV JSON file and returns a fully parsed [Bible].
  ///
  /// This is an expensive operation (7 MB parse). Call it once at startup
  /// and cache the result inside [BibleRepository].
  Future<Bible> load() async {
    final rawJson = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    return Bible.fromJson(decoded);
  }
}
