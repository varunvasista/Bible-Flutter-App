import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/services/service_locator.dart';
import '../../bible/screens/verse_reader_screen.dart';
import '../../journal/models/verse_of_day.dart';
import '../../journal/widgets/prayer_point_list.dart';
import '../../journal/widgets/verse_of_day_card.dart';
import '../../reading_plan/services/reading_plan_service.dart';
import '../../settings/screens/settings_screen.dart';
import '../services/reading_progress_service.dart';
import '../widgets/continue_reading_card.dart';
import '../widgets/reading_plan_progress_card.dart';
import '../widgets/greeting_header.dart';
import '../widgets/reminder_summary_card.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  VerseOfDay? _verse;
  List<String> _prayers = [];
  bool _isLoading = true;
  bool _hasLoadError = false;

  ReadingPosition? _readingPosition;
  ReadingPlanProgress? _planProgress;
  ReadingPlanDay? _todayAssignment;
  ReadingPlan? _activePlan;
  int _streak = 0;
  TimeOfDay _bibleReminderTime = const TimeOfDay(hour: 7, minute: 0);
  bool _bibleReminderEnabled = true;
  TimeOfDay _prayerReminderTime = const TimeOfDay(hour: 7, minute: 40);
  bool _prayerReminderEnabled = true;

  @override
  void initState() {
    super.initState();
    journalRefreshNotifier.addListener(_onRefresh);
    appPreferencesNotifier.addListener(_onRefresh);
    bibleDatasetReadyNotifier.addListener(_onBibleDatasetReady);
    bibleDatasetInitInProgressNotifier
        .addListener(_onBibleDatasetInitStatusChanged);
    _loadTodayData();
  }

  @override
  void dispose() {
    journalRefreshNotifier.removeListener(_onRefresh);
    appPreferencesNotifier.removeListener(_onRefresh);
    bibleDatasetReadyNotifier.removeListener(_onBibleDatasetReady);
    bibleDatasetInitInProgressNotifier.removeListener(
      _onBibleDatasetInitStatusChanged,
    );
    super.dispose();
  }

  void _onRefresh() => _loadTodayData();

  void _onBibleDatasetReady() {
    if (!mounted) return;
    if (bibleDatasetReadyNotifier.value) {
      _loadTodayData();
    }
  }

  void _onBibleDatasetInitStatusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  static const VerseOfDay _defaultEncouragementVerse = VerseOfDay(
    reference: 'Psalm 46:10',
    text: 'Be still, and know that I am God.',
    emotion: 'daily',
  );

  Future<void> _loadTodayData() async {
    // Use Future.any() to add a 5-second timeout protection
    try {
      await Future.any([
        _loadTodayDataInternal(),
        Future.delayed(const Duration(seconds: 5)).then(
          (_) => throw TimeoutException(
            'Home screen data loading timed out after 5 seconds',
          ),
        ),
      ]);
    } catch (e) {
      debugPrint('TodayScreen: data loading timeout or error: $e');
      if (!mounted) return;
      setState(() {
        _verse ??= _defaultEncouragementVerse;
        if (_prayers.isEmpty) {
          _prayers = const [
            'Pause and breathe. God is with you in this moment.',
            'Ask God for wisdom and peace for what lies ahead.',
            'Thank Him for His faithfulness today.',
          ];
        }
        _hasLoadError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTodayDataInternal() async {
    try {
      debugPrint(
          'TodayScreen: Bible dataset ready=${bibleDatasetReadyNotifier.value}');

      final latestEntry = journalRepo.getLatestEntry();
      final verse = await verseOfDayService.getVerseOfTheDay();
      final prayers = await prayerPointService.getPrayerPointsForToday(
        latestJournal: latestEntry,
      );

      final position = await readingProgressService.getLastReadingPosition();
      final progress = await readingPlanService.getProgress();
      final assignment = await readingPlanService.getTodayAssignment();
      final reminderSettings = await reminderService.loadSettings();

      if (!mounted) return;
      setState(() {
        _verse = verse;
        _prayers = prayers;
        _readingPosition = position;
        _planProgress = progress;
        _todayAssignment = assignment;
        _activePlan = readingPlanService.getPlanByName(progress.planName);
        _streak = streakService.getCurrentStreak();
        _bibleReminderTime = reminderSettings.bibleReadingTime;
        _bibleReminderEnabled = reminderSettings.bibleReadingEnabled;
        _prayerReminderTime = reminderSettings.prayerTime;
        _prayerReminderEnabled = reminderSettings.prayerEnabled;
        _hasLoadError = false;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('TodayScreen: verse loading failed: $e');
      if (!mounted) return;
      setState(() {
        _verse = _defaultEncouragementVerse;
        _prayers = const [
          'Pause and breathe. God is with you in this moment.',
          'Ask God for wisdom and peace for what lies ahead.',
          'Thank Him for His faithfulness today.',
        ];
        _hasLoadError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _openContinueReading() async {
    final position = _readingPosition;
    if (position == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerseReaderScreen(
          translation: position.translation,
          bookName: position.book,
          initialChapter: position.chapter,
        ),
      ),
    );
    if (!mounted) return;
    await _loadTodayData();
    await _showPlanCompletionIfNeeded();
  }

  Future<void> _openTodayPlanReading() async {
    final assignment = _todayAssignment;
    if (assignment == null) return;

    final preferredTranslation = settingsService.preferredTranslation.isNotEmpty
        ? settingsService.preferredTranslation
        : 'NLT';
    await bibleRepo.ensureLoaded(preferredTranslation);
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerseReaderScreen(
          translation: preferredTranslation,
          bookName: assignment.book,
          initialChapter: assignment.chapter,
        ),
      ),
    );
    if (!mounted) return;
    await _loadTodayData();
    await _showPlanCompletionIfNeeded();
  }

  Future<void> _showPlanCompletionIfNeeded() async {
    final shouldShow = await readingPlanService.shouldShowCompletionPopup();
    if (!mounted || !shouldShow) return;

    await readingPlanService.markCompletionPopupShown();
    if (!mounted) return;
    await _showReadingPlanCompletedDialog();
  }

  Future<void> _showReadingPlanCompletedDialog() async {
    final colorScheme = Theme.of(context).colorScheme;

    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Reading Plan Completed',
      barrierDismissible: true,
      barrierColor: AppColors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, _, __) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: Dialog(
              elevation: 0,
              backgroundColor: AppColors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderDark, width: 1.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          size: 42,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Well done!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You have completed your Bible reading plan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.35,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '2 Timothy 3:16',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'All Scripture is God-breathed and is useful for teaching, rebuking, correcting and training in righteousness.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: accessibilityService.largeVerseText
                                    ? 18.0
                                    : 13.5,
                                height: 1.35,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.black,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Continue',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final verse = _verse;
    final plan = _activePlan;
    final progress = _planProgress;
    final assignment = _todayAssignment;
    final bibleReady = localBibleService.isLoaded;
    final bibleInitInProgress = bibleDatasetInitInProgressNotifier.value;

    if (_isLoading || (!bibleReady && bibleInitInProgress)) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!bibleReady && _hasLoadError) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Unable to load full Bible data. Showing fallback verse.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  VerseOfDayCard(
                    verse: _verse ?? _defaultEncouragementVerse,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        _isLoading = true;
                        _hasLoadError = false;
                      });
                      _loadTodayData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTodayData,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              GreetingHeader(
                greeting: _greeting(),
                streak: _streak,
              ),
              const SizedBox(height: 20),
              if (verse != null) VerseOfDayCard(verse: verse),
              const SizedBox(height: 20),
              ContinueReadingCard(
                position: _readingPosition,
                onContinue: _openContinueReading,
              ),
              const SizedBox(height: 20),
              PrayerPointList(prayers: _prayers),
              const SizedBox(height: 20),
              if (plan != null && progress != null && assignment != null) ...[
                ReadingPlanProgressCard(
                  plan: plan,
                  completedDays: progress.completedDays,
                  todayAssignment: assignment,
                ),
                const SizedBox(height: 20),
              ],
              ReminderSummaryCard(
                bibleReminderEnabled: _bibleReminderEnabled,
                bibleReminderTime: _bibleReminderTime,
                prayerReminderEnabled: _prayerReminderEnabled,
                prayerReminderTime: _prayerReminderTime,
                onOpenPlanReading: _openTodayPlanReading,
                onOpenJournal: () => tabSwitchRequest.value = 2,
                onOpenSettings: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
