import 'package:flutter/material.dart';

import '../../../core/services/service_locator.dart';
import '../models/verse_of_day.dart';
import '../widgets/prayer_point_list.dart';
import '../widgets/verse_of_day_card.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Static list of journaling prompts shown in rotation based on day-of-year.
const _journalPrompts = [
  "What is one thing God has done for you this week that you haven\u2019t thanked Him for yet?",
  "Where have you been relying on yourself instead of trusting God?",
  "What fear has been holding you back from stepping into God\u2019s calling?",
  "Is there someone you need to forgive \u2014 including yourself?",
  "What area of your life needs more of God\u2019s presence today?",
  "What does being still before God look and feel like for you right now?",
  "Where have you seen God\u2019s faithfulness in a season you almost gave up?",
  "What habit or thought pattern would you like God to renew in you?",
  "Who can you encourage or pray for today?",
  "What promise from Scripture do you need to stand on right now?",
];

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  VerseOfDay? _verse;
  List<String> _prayers = [];
  String _journalPrompt = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    journalRefreshNotifier.addListener(_onRefresh);
    _loadTodayData();
  }

  @override
  void dispose() {
    journalRefreshNotifier.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() => _loadTodayData();

  Future<void> _loadTodayData() async {
    final latestEntry = journalRepo.getLatestEntry();
    final emotions =
        latestEntry != null && latestEntry.detectedEmotions.isNotEmpty
            ? latestEntry.detectedEmotions
            : ['peace'];

    final verse =
        await verseSuggestionService.getVerseForEmotion(emotions.first);
    final prayers = prayerGeneratorService.generatePrayerPoints(emotions);

    final dayOfYear = DateTime.now()
        .difference(
          DateTime(DateTime.now().year, 1, 1),
        )
        .inDays;
    final prompt = _journalPrompts[dayOfYear % _journalPrompts.length];

    setState(() {
      _verse = verse;
      _prayers = prayers;
      _journalPrompt = prompt;
      _isLoading = false;
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async => _loadTodayData(),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    // ── Header ───────────────────────────────────────────
                    _Header(greeting: _greeting()),

                    const SizedBox(height: 20),

                    // ── Verse of the Day ─────────────────────────────────
                    if (_verse != null) VerseOfDayCard(verse: _verse!),

                    const SizedBox(height: 24),

                    // ── Prayer Points ────────────────────────────────────
                    PrayerPointList(prayers: _prayers),

                    const SizedBox(height: 24),

                    // ── Journal Prompt ───────────────────────────────────
                    _JournalPromptCard(prompt: _journalPrompt),

                    const SizedBox(height: 24),

                    // ── Journal Quick-link ───────────────────────────────
                    _JournalPromptBanner(),
                  ],
                ),
              ),
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Today\'s Spiritual Focus',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalPromptCard extends StatelessWidget {
  const _JournalPromptCard({required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 15, color: AppColors.black),
              SizedBox(width: 6),
              Text(
                'NOTES PROMPT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            prompt,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.black,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalPromptBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entryCount = journalRepo.count;
    final hasEntryToday = () {
      final latest = journalRepo.getLatestEntry();
      if (latest == null) return false;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      return latest.dateKey == today;
    }();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_note_rounded,
              size: 28, color: AppColors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasEntryToday
                      ? 'You\'ve taken notes today!'
                      : 'Write in your notes',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasEntryToday
                      ? '$entryCount ${entryCount == 1 ? 'entry' : 'entries'} in your notes'
                      : 'Capture your thoughts — they shape your prayer.',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
