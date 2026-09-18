import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StreakState {
  const StreakState({required this.currentStreak, required this.lastOpenDate});

  final int currentStreak;
  final String lastOpenDate;

  Map<String, dynamic> toJson() => {
        'current_streak': currentStreak,
        'last_open_date': lastOpenDate,
      };

  factory StreakState.fromJson(Map<String, dynamic> json) {
    return StreakState(
      currentStreak: json['current_streak'] as int,
      lastOpenDate: json['last_open_date'] as String,
    );
  }
}

/// Tracks consecutive app-open days using local device storage.
class StreakService {
  static const _prefsKey = 'streak_state';

  int _currentStreak = 0;

  int getCurrentStreak() => _currentStreak;

  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final today = _dateOnly(DateTime.now());

    if (raw == null || raw.isEmpty) {
      _currentStreak = 1;
      await _save(
        StreakState(currentStreak: _currentStreak, lastOpenDate: today),
      );
      return;
    }

    try {
      final current = StreakState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final last = DateTime.parse(current.lastOpenDate);
      final now = DateTime.now();
      final dayDiff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(last.year, last.month, last.day))
          .inDays;

      if (dayDiff == 0) {
        _currentStreak = current.currentStreak;
      } else if (dayDiff == 1) {
        _currentStreak = current.currentStreak + 1;
      } else {
        _currentStreak = 1;
      }

      await _save(StreakState(currentStreak: _currentStreak, lastOpenDate: today));
    } catch (_) {
      _currentStreak = 1;
      await _save(StreakState(currentStreak: _currentStreak, lastOpenDate: today));
    }
  }

  Future<void> loadCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      _currentStreak = 0;
      return;
    }
    try {
      final state = StreakState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _currentStreak = state.currentStreak;
    } catch (_) {
      _currentStreak = 0;
    }
  }

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _save(StreakState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(state.toJson()));
  }
}
