import 'dart:async';

import 'package:bible_app/data/repositories/bible_repository.dart';
import 'package:flutter/material.dart';

import 'ai/services/gemma_model_service.dart';
import 'ai/services/emotion_detection_service.dart';
import 'ai/services/emotion_verses_repository.dart';
import 'ai/services/spiritual_guidance_service.dart';
import 'ai/services/journal_reflection_service.dart';
import 'core/services/service_locator.dart';
import 'core/services/local_bible_service.dart';
import 'data/datasources/favorites_service.dart';
import 'features/journal/repositories/journal_repository.dart';
import 'features/journal/services/journal_storage_service.dart';
import 'features/journal/services/prayer_generator_service.dart';
import 'features/journal/services/verse_suggestion_service.dart';
import 'features/bible/services/bible_search_service.dart';
import 'features/bible/services/bookmark_service.dart';
import 'features/bible/services/highlight_service.dart';
import 'features/reading_plan/services/reading_plan_service.dart';
import 'features/home/services/reading_progress_service.dart';
import 'features/reminders/services/reminder_service.dart';
import 'features/home/services/streak_service.dart';
import 'features/home/services/verse_of_day_service.dart';
import 'features/home/services/prayer_point_service.dart';
import 'features/settings/services/accessibility_service.dart';
import 'features/settings/services/bible_cache_service.dart';
import 'features/settings/services/data_export_service.dart';
import 'features/settings/services/settings_service.dart';

import 'routes/app_router.dart';
import 'package:bible_app/core/theme/app_colors.dart';

Future<void> main() async {
  final stopwatch = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('App started');

  // Wire up service instances first so the UI can render immediately.
  favoritesService = FavoritesService();

  // Journal services.
  final journalStorage = JournalStorageService();
  journalRepo = JournalRepository(storage: journalStorage);
  emotionDetectionService = EmotionDetectionService();
  prayerGeneratorService = PrayerGeneratorService();

  // Bible Step 6 services.
  bibleSearchService = BibleSearchService(repository: bibleRepo);
  final bookmarkStorage = BookmarkService();
  bookmarkService = bookmarkStorage;
  final highlightStorage = HighlightService();
  highlightService = highlightStorage;

  // Home Step 7 services.
  readingProgressService = ReadingProgressService();
  readingPlanService = ReadingPlanService(repository: bibleRepo);
  streakService = StreakService();
  reminderService = ReminderService();

  // Local AI (Gemma) service.
  gemmaModelService = GemmaModelService();
  localBibleService = LocalBibleService(repository: bibleRepo);
  bibleDatasetReadyNotifier.value = false;
  bibleDatasetInitInProgressNotifier.value = false;
  aiModelReadyNotifier.value = false;
  aiModelInitInProgressNotifier.value = false;

  // RAG pipeline services (offline local Bible + guidance + journal AI).
  // Shared emotion → verse map (loaded once, injected into both RAG services).
  emotionVersesRepository = EmotionVersesRepository();

  // verseSuggestionService is wired here after LocalBibleService is ready so
  // all verse lookups come from the bundled NLT dataset.
  verseSuggestionService = VerseSuggestionService(
    bibleRepo: bibleRepo,
    localBible: localBibleService,
  );
  verseOfDayService = VerseOfDayService(
    localBible: localBibleService,
  );
  prayerPointService = PrayerPointService(
    emotionDetection: emotionDetectionService,
    modelService: gemmaModelService,
    verseSuggestionService: verseSuggestionService,
  );

  spiritualGuidanceService = SpiritualGuidanceService(
    emotionDetection: emotionDetectionService,
    localBible: localBibleService,
    emotionVerses: emotionVersesRepository,
    modelService: gemmaModelService,
  );
  journalReflectionService = JournalReflectionService(
    emotionDetection: emotionDetectionService,
    localBible: localBibleService,
    emotionVerses: emotionVersesRepository,
    modelService: gemmaModelService,
  );

  // Settings Step 8 services.
  settingsService = SettingsService();
  accessibilityService = AccessibilityService();
  dataExportService = DataExportService();
  bibleCacheService = BibleCacheService(repository: bibleRepo);

  // Initialize settings and eagerly load default translation (NLT)
  // before rendering the app to avoid synchronous lookup errors.
  try {
    await settingsService.init();
    final preferred = settingsService.preferredTranslation;
    if (preferred.isNotEmpty) {
      await bibleRepo.ensureLoaded(preferred);
    }
    await bibleRepo.ensureLoaded(BibleRepository.defaultTranslation);
  } catch (e) {
    debugPrint('Critical initialization failed: $e');
  }

  // Ensure native splash screen stays for approximately 2–3 seconds (2.5 seconds total)
  final elapsed = stopwatch.elapsedMilliseconds;
  final remaining = 2500 - elapsed;
  if (remaining > 0) {
    await Future.delayed(Duration(milliseconds: remaining));
  }

  runApp(const BibleApp());

  Future.microtask(_warmStartServices);
}

Future<void> _warmStartServices() async {
  debugPrint('========== WARM START SERVICES BEGIN ==========');
  // Core datasets

  // Persisted/local services
  try {
    await favoritesService.init();
  } catch (e) {
    debugPrint('Favorites init failed: $e');
  }
  try {
    await journalRepo.storage.init();
  } catch (e) {
    debugPrint('Journal storage init failed: $e');
  }
  try {
    await bookmarkService.init();
  } catch (e) {
    debugPrint('Bookmark init failed: $e');
  }
  try {
    await highlightService.init();
  } catch (e) {
    debugPrint('Highlight init failed: $e');
  }
  try {
    await readingPlanService.init();
  } catch (e) {
    debugPrint('ReadingPlanService init failed: $e');
  }
  try {
    await streakService.updateStreak();
  } catch (e) {
    debugPrint('Streak update failed: $e');
  }
  try {
    await reminderService.init(
      onOpenToday: () => tabSwitchRequest.value = 0,
    );
    await reminderService.rescheduleAll();
  } catch (e) {
    debugPrint('Reminder service init failed: $e');
  }
  try {
    await settingsService.init();
  } catch (e) {
    debugPrint('Settings init failed: $e');
  }
  try {
    await accessibilityService.init();
  } catch (e) {
    debugPrint('Accessibility init failed: $e');
  }
  try {
    await emotionVersesRepository.init();
  } catch (e) {
    debugPrint('EmotionVersesRepository init failed: $e');
  }

  // Sync plan after settings are loaded.
  try {
    await readingPlanService.selectPlan(settingsService.selectedReadingPlan);
  } catch (e) {
    debugPrint('Reading plan sync failed: $e');
  }

  // Keep preferred translation loaded for reader screens.
  // Also eagerly load NLT since several services (and fallbacks) assume it.
  try {
    final preferred = settingsService.preferredTranslation;
    if (preferred.isNotEmpty) {
      await bibleRepo.ensureLoaded(preferred);
    }
    await bibleRepo.ensureLoaded(BibleRepository.defaultTranslation);
  } catch (e) {
    debugPrint('Preferred translation load failed: $e');
  }

  try {
    await bibleRepo.ensureLoaded('NLT');
  } catch (e) {
    debugPrint('NLT translation load failed: $e');
  }

  debugPrint('Loaded translations after warm start: '
      '${bibleRepo.getLoadedTranslations()}');

  // Heavy Bible/model initialization is triggered by HomeScreen in background
  // with timeout protection, so startup is never blocked.

  debugPrint('========== WARM START SERVICES COMPLETE ==========');
  debugPrint('Bible loaded: ${localBibleService.isLoaded}');
  debugPrint('Gemma ready: ${gemmaModelService.isReady}');
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = isDark
        ? const ColorScheme.dark(
            primary: AppColors.white,
            secondary: AppColors.white,
            surface: AppColors.kyrieDarkGrey,
            onSurface: AppColors.white,
            onPrimary: AppColors.black,
          ).copyWith(
            surfaceContainerHighest: AppColors.kyrieDarkGrey,
            surfaceContainerHigh: AppColors.kyrieDarkGrey,
            surfaceContainer: AppColors.kyrieDarkGrey,
            surfaceContainerLow: AppColors.kyrieDarkGrey,
            surfaceContainerLowest: AppColors.kyrieDarkGrey,
          )
        : const ColorScheme.light(
            primary: AppColors.black,
            secondary: AppColors.black,
            surface: AppColors.white,
            onSurface: AppColors.black,
            onPrimary: AppColors.white,
          ).copyWith(
            surfaceContainerHighest: AppColors.white,
            surfaceContainerHigh: AppColors.white,
            surfaceContainer: AppColors.white,
            surfaceContainerLow: AppColors.white,
            surfaceContainerLowest: AppColors.white,
          );

    final base = ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkGray : AppColors.background,
      useMaterial3: true,
      fontFamily: 'Georgia',
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark ? AppColors.white : AppColors.primary;
          }
          return isDark ? AppColors.disabledGrey : AppColors.greyLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return (isDark ? AppColors.white : AppColors.primary)
                .withOpacity(0.38);
          }
          return isDark ? AppColors.kyrieDarkGrey : AppColors.greyLightest;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: isDark ? AppColors.white : AppColors.primary,
        inactiveTrackColor:
            isDark ? AppColors.kyrieDarkGrey : AppColors.greyLightest,
        thumbColor: isDark ? AppColors.white : AppColors.primary,
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.kyrieDarkGrey : AppColors.white,
        elevation: 0,
        shadowColor: AppColors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.kyrieDarkGrey : AppColors.white,
        surfaceTintColor: AppColors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.kyrieDarkGrey : AppColors.white,
        surfaceTintColor: AppColors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.transparent,
        foregroundColor: isDark ? AppColors.white : AppColors.primary,
        elevation: 0,
        iconTheme:
            IconThemeData(color: isDark ? AppColors.white : AppColors.primary),
        actionsIconTheme:
            IconThemeData(color: isDark ? AppColors.white : AppColors.primary),
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.white : AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Georgia',
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkGray : AppColors.white,
        selectedItemColor: isDark ? AppColors.white : AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? AppColors.white : AppColors.primary,
          foregroundColor: isDark ? AppColors.black : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.white : AppColors.primary,
          side: BorderSide(
              color: isDark ? AppColors.white : AppColors.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );

    final textTheme = base.textTheme.apply(
      bodyColor: accessibilityService.highContrast
          ? (isDark ? AppColors.white : AppColors.black)
          : (isDark ? AppColors.white : AppColors.primary),
      displayColor: accessibilityService.highContrast
          ? (isDark ? AppColors.white : AppColors.black)
          : (isDark ? AppColors.white : AppColors.primary),
    );

    return base.copyWith(textTheme: textTheme);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: appPreferencesNotifier,
      builder: (_, __, ___) => MaterialApp(
        title: 'Bible App',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light),
        initialRoute: AppRouter.onboarding,
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(accessibilityService.fontScale),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
