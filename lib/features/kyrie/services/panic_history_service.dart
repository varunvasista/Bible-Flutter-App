import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Represents a single past spiritual guidance session.
class PanicHistoryEntry {
  const PanicHistoryEntry({
    required this.id,
    required this.date,
    required this.userMessage,
    required this.responseId,
    required this.createdAt,
  });

  /// Milliseconds-since-epoch as a string — unique identifier.
  final String id;

  /// Calendar date key, e.g. '2026-03-12'.
  final String date;

  final String userMessage;
  final String responseId;
  final DateTime createdAt;

  factory PanicHistoryEntry.fromJson(Map<String, dynamic> json) =>
      PanicHistoryEntry(
        id: json['id'] as String,
        date: json['date'] as String,
        userMessage: json['user_message'] as String,
        responseId: json['response_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'user_message': userMessage,
        'response_id': responseId,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Stores and retrieves [PanicHistoryEntry] objects via [SharedPreferences].
///
/// Entries are stored newest-first and capped at [maxEntries].
class PanicHistoryService {
  static const String _prefsKey = 'panic_history';
  static const int maxEntries = 50;

  List<PanicHistoryEntry> _entries = [];

  /// Loads persisted history from SharedPreferences.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    _entries = raw.map((s) {
      try {
        return PanicHistoryEntry.fromJson(
            jsonDecode(s) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<PanicHistoryEntry>().toList();

    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<PanicHistoryEntry> getAllEntries() => List.unmodifiable(_entries);

  PanicHistoryEntry? getLatestEntry() =>
      _entries.isEmpty ? null : _entries.first;

  int get count => _entries.length;

  Future<void> saveEntry(String userMessage, String responseId) async {
    final now = DateTime.now();
    final entry = PanicHistoryEntry(
      id: now.millisecondsSinceEpoch.toString(),
      date: now.toIso8601String().substring(0, 10),
      userMessage: userMessage,
      responseId: responseId,
      createdAt: now,
    );

    _entries.insert(0, entry);

    if (_entries.length > maxEntries) {
      _entries = _entries.sublist(0, maxEntries);
    }

    await _persist();
  }

  Future<void> clearAll() async {
    _entries = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_prefsKey, raw);
  }
}
