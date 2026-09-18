import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_verse.dart';

/// Persists favorite Bible verses locally using [SharedPreferences].
///
/// All lookups are synchronous (in-memory Map). Writes are async (flush to
/// SharedPreferences after every change).
class FavoritesService {
  static const String _prefsKey = 'favorite_verses';

  final Map<String, FavoriteVerse> _cache = {};

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Loads previously saved favorites from SharedPreferences into memory.
  /// Call once at app startup before [runApp].
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    for (final item in raw) {
      try {
        final fv = FavoriteVerse.fromJson(
          jsonDecode(item) as Map<String, dynamic>,
        );
        _cache[fv.id] = fv;
      } catch (_) {
        // Skip malformed entries rather than crashing.
      }
    }
  }

  // ── Lookups (synchronous) ─────────────────────────────────────────────────

  /// Whether the verse identified by [id] is currently saved.
  bool isFavorite(String id) => _cache.containsKey(id);

  /// Returns all saved favorites sorted newest-first.
  List<FavoriteVerse> getAllFavorites() => _cache.values.toList()
    ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

  int get count => _cache.length;

  // ── Mutations (async) ─────────────────────────────────────────────────────

  /// Saves [verse] if not already saved; removes it if it is.
  Future<void> toggleFavorite(FavoriteVerse verse) async {
    if (_cache.containsKey(verse.id)) {
      _cache.remove(verse.id);
    } else {
      _cache[verse.id] = verse;
    }
    await _persist();
  }

  Future<void> addFavorite(FavoriteVerse verse) async {
    _cache[verse.id] = verse;
    await _persist();
  }

  Future<void> removeFavorite(String id) async {
    _cache.remove(id);
    await _persist();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _cache.values.map((v) => jsonEncode(v.toJson())).toList(),
    );
  }

  Future<void> clearAll() async {
    _cache.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
