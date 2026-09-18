import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/service_locator.dart';

class DataExportService {
  /// Exports core user data to a local JSON file and returns the file path.
  Future<String> exportUserData() async {
    final now = DateTime.now();
    final timestamp = now.toIso8601String().replaceAll(':', '-');

    final journal = journalRepo.getAllEntries().map((e) => e.toJson()).toList();
    final bookmarks = bookmarkService
        .getBookmarks()
        .map((v) => {
              'translation': v.translation,
              'book': v.book,
              'chapter': v.chapter,
              'verse': v.verse,
              'text': v.text,
            })
        .toList();
    final highlights = highlightService.getHighlights();
    final readingPosition = await readingProgressService.getLastReadingPosition();
    final planProgress = await readingPlanService.getProgress();
    final reminderTime = await settingsService.getReminderTime();

    final data = {
      'exported_at': now.toIso8601String(),
      'settings': {
        'preferred_translation': settingsService.preferredTranslation,
        'font_scale': accessibilityService.fontScale,
        'high_contrast': accessibilityService.highContrast,
        'large_verse_text': accessibilityService.largeVerseText,
        'reminder_time':
            '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}',
      },
      'journal_entries': journal,
      'bookmarks': bookmarks,
      'highlights': highlights,
      'reading_progress': readingPosition == null
          ? null
          : {
              'translation': readingPosition.translation,
              'book': readingPosition.book,
              'chapter': readingPosition.chapter,
            },
      'reading_plan': {
        'plan_name': planProgress.planName,
        'completed_days': planProgress.completedDays,
      },
      'streak': {
        'current_streak': streakService.getCurrentStreak(),
      },
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/bible_app_export_$timestamp.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file.path;
  }

  /// Resets locally stored app data (SharedPreferences + export files).
  Future<void> resetAllData() async {
    try {
      await bookmarkService.clearAll();
    } catch (_) {}
    try {
      await highlightService.clearAll();
    } catch (_) {}
    try {
      await favoritesService.clearAll();
    } catch (_) {}
    try {
      await journalRepo.clearAll();
    } catch (_) {}
    try {
      await readingProgressService.clearAll();
    } catch (_) {}
    try {
      await readingPlanService.clearAll();
    } catch (_) {}
    try {
      await reminderService.cancelAllReminders();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final dir = await getApplicationDocumentsDirectory();
    if (await dir.exists()) {
      final entities = dir.listSync();
      for (final entity in entities) {
        if (entity is File && entity.path.contains('bible_app_export_')) {
          try {
            await entity.delete();
          } catch (_) {
            // Ignore file delete failures.
          }
        }
      }
    }
  }
}
