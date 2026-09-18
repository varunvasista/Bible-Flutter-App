import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';

/// Persists and retrieves [JournalEntry] objects using [SharedPreferences].
///
/// Entries are stored as a JSON array of serialised [JournalEntry] objects
/// under the key [_prefsKey]. The list is capped at [maxEntries] to prevent
/// unbounded storage growth.
class JournalStorageService {
  static const String _prefsKey = 'journal_entries';
  static const int maxEntries = 200;

  List<JournalEntry> _entries = [];

  /// Loads persisted entries from SharedPreferences.
  ///
  /// Must be called (and awaited) before any other method.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    _entries = raw.map((s) {
      try {
        return JournalEntry.fromJson(jsonDecode(s) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<JournalEntry>().toList();

    // Newest first.
    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<JournalEntry> getAllEntries() => List.unmodifiable(_entries);

  JournalEntry? getLatestEntry() => _entries.isEmpty ? null : _entries.first;

  Future<void> saveEntry(JournalEntry entry) async {
    _entries.insert(0, entry);

    // Trim to max.
    if (_entries.length > maxEntries) {
      _entries = _entries.sublist(0, maxEntries);
    }

    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_prefsKey, raw);
  }

  Future<void> clearAll() async {
    _entries = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
