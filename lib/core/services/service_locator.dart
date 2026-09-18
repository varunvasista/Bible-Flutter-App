import 'package:flutter/foundation.dart';

import '../../ai/services/emotion_detection_service.dart';
import '../../ai/services/emotion_verses_repository.dart';
import '../../ai/services/gemma_model_service.dart';
import '../../ai/services/journal_reflection_service.dart';
import '../../ai/services/spiritual_guidance_service.dart';
import '../../data/repositories/bible_repository.dart';
import '../../data/datasources/favorites_service.dart';
import 'local_bible_service.dart';
import '../../features/journal/repositories/journal_repository.dart';
import '../../features/journal/services/prayer_generator_service.dart';
import '../../features/journal/services/verse_suggestion_service.dart';
import '../../features/bible/services/bible_search_service.dart';
import '../../features/bible/services/bookmark_service.dart';
import '../../features/bible/services/highlight_service.dart';
import '../../features/home/services/prayer_point_service.dart';
import '../../features/reading_plan/services/reading_plan_service.dart';
import '../../features/home/services/reading_progress_service.dart';
import '../../features/reminders/services/reminder_service.dart';
import '../../features/home/services/streak_service.dart';
import '../../features/home/services/verse_of_day_service.dart';
import '../../features/settings/services/accessibility_service.dart';
import '../../features/settings/services/bible_cache_service.dart';
import '../../features/settings/services/data_export_service.dart';
import '../../features/settings/services/settings_service.dart';

/// Global singleton service/repository instances used across the app.
///
/// Service instances are created before [runApp] and warmed up in background.
final bibleRepo = BibleRepository();
late final FavoritesService favoritesService;

// ── Journal ──────────────────────────────────────────────────────────────────
late final JournalRepository journalRepo;
late final EmotionDetectionService emotionDetectionService;
late final VerseSuggestionService verseSuggestionService;
late final PrayerGeneratorService prayerGeneratorService;
late final VerseOfDayService verseOfDayService;
late final PrayerPointService prayerPointService;

/// Incremented each time a journal entry is saved.
///
/// [TodayScreen] listens to this notifier so it refreshes automatically after
/// the user saves a new entry in the Journal tab.
final journalRefreshNotifier = ValueNotifier<int>(0);

// ── Bible Step 6 ─────────────────────────────────────────────────────────────
late final BibleSearchService bibleSearchService;
late final BookmarkService bookmarkService;
late final HighlightService highlightService;

// ── Home Step 7 ──────────────────────────────────────────────────────────────
late final ReadingProgressService readingProgressService;
late final ReadingPlanService readingPlanService;
late final StreakService streakService;
late final ReminderService reminderService;

// ── Local AI Step 9 ─────────────────────────────────────────────────────────
late final GemmaModelService gemmaModelService;
late final LocalBibleService localBibleService;
final bibleDatasetReadyNotifier = ValueNotifier<bool>(false);
final bibleDatasetInitInProgressNotifier = ValueNotifier<bool>(false);
final aiModelReadyNotifier = ValueNotifier<bool>(false);
final aiModelInitInProgressNotifier = ValueNotifier<bool>(false);

// ── RAG Pipeline ─────────────────────────────────────────────────────────────
late final EmotionVersesRepository emotionVersesRepository;
late final SpiritualGuidanceService spiritualGuidanceService;
late final JournalReflectionService journalReflectionService;

// ── Settings Step 8 ──────────────────────────────────────────────────────────
late final SettingsService settingsService;
late final AccessibilityService accessibilityService;
late final DataExportService dataExportService;
late final BibleCacheService bibleCacheService;

/// Bump this notifier whenever theme/accessibility/settings should rebuild the app shell.
final appPreferencesNotifier = ValueNotifier<int>(0);

/// Bump this notifier when app data reset is performed to reset home screen navigators.
final appResetNotifier = ValueNotifier<int>(0);



/// Set to a tab index to programmatically switch the HomeScreen tab.
///
/// Example: setting this to `1` switches to the Bible tab.
/// [HomeScreen] listens to this notifier and resets it to `null` after use.
final tabSwitchRequest = ValueNotifier<int?>(null);
