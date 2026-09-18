import 'package:flutter/material.dart';

import '../../../data/models/panic_response.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Displays the full structured response from the panic dataset.
///
/// Sections rendered:
///   • Understanding the Situation
///   • Biblical Explanation
///   • Biblical Story Example
///   • Recommended Verses  (tappable chips → [onVerseTap])
///   • Short Prayer        (highlighted gradient card)
///
/// Pass [onVerseTap] to handle verse-chip taps (e.g. show a bottom sheet).
class PanicResponseCard extends StatelessWidget {
  const PanicResponseCard({
    super.key,
    required this.panicResponse,
    this.onVerseTap,
  });

  final PanicResponse panicResponse;

  /// Called with the verse reference string when a verse chip is tapped.
  final void Function(String verseRef)? onVerseTap;

  @override
  Widget build(BuildContext context) {
    final r = panicResponse.response;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(
          icon: Icons.favorite_border_rounded,
          title: 'Understanding the Situation',
          body: r.understandingUserQuery,
          iconColor: AppColors.error,
        ),
        _Section(
          icon: Icons.menu_book_rounded,
          title: 'Biblical Explanation',
          body: r.biblicalExplanation,
          iconColor: AppColors.accentPurple,
        ),
        _Section(
          icon: Icons.history_edu_rounded,
          title: 'Biblical Story Example',
          body: r.biblicalStoryExample,
          iconColor: AppColors.accentBlue,
        ),
        _VerseSection(verses: r.recommendedVerses, onVerseTap: onVerseTap),
        _PrayerSection(prayer: r.shortPrayer),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderDark,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.65,
              color: AppColors.greyDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerseSection extends StatelessWidget {
  const _VerseSection({required this.verses, this.onVerseTap});

  final List<String> verses;
  final void Function(String)? onVerseTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderDark,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark_rounded,
                  color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Recommended Verses',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
              if (onVerseTap != null) ...[
                const Spacer(),
                const Text(
                  'Tap to read',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: verses.map((v) {
              if (onVerseTap != null) {
                return ActionChip(
                  label: Text(
                    v,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  backgroundColor: AppColors.borderLight,
                  side: const BorderSide(color: AppColors.borderDark),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  avatar: const Icon(Icons.open_in_new_rounded,
                      size: 13, color: AppColors.black),
                  onPressed: () => onVerseTap!(v),
                );
              }
              return Chip(
                label: Text(
                  v,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                backgroundColor: AppColors.borderLight,
                side: const BorderSide(color: AppColors.borderDark),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PrayerSection extends StatelessWidget {
  const _PrayerSection({required this.prayer});

  final String prayer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderDark,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.volunteer_activism_rounded,
                  color: AppColors.black, size: 18),
              SizedBox(width: 8),
              Text(
                'Short Prayer',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            prayer,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: AppColors.greyDark,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
