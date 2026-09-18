import 'package:flutter/material.dart';

import '../../../data/models/bible_verse.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class VerseTile extends StatelessWidget {
  const VerseTile({
    super.key,
    required this.verse,
    required this.translation,
    required this.bookName,
    required this.chapterNumber,
    required this.highlightColor,
    required this.isBookmarked,
    required this.onToggleBookmark,
    required this.onChooseHighlight,
    required this.onShare,
    required this.fontScale,
    required this.highContrast,
    required this.largeVerseText,
  });

  final BibleVerse verse;
  final String translation;
  final String bookName;
  final int chapterNumber;
  final Color? highlightColor;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;
  final VoidCallback onChooseHighlight;
  final VoidCallback onShare;
  final double fontScale;
  final bool highContrast;
  final bool largeVerseText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseSize = largeVerseText ? 24.0 : 18.0;
    final verseFontSize = baseSize * fontScale;
    final verseColor = highContrast
        ? Theme.of(context).colorScheme.onSurface
        : (isDark ? AppColors.white : AppColors.primary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: highlightColor ?? (isDark ? AppColors.kyrieDarkGrey : AppColors.background),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkGray : AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.01),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse Number
          SizedBox(
            width: 24,
            child: Text(
              '${verse.verse}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: isDark ? AppColors.white.withOpacity(0.7) : AppColors.primary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Verse Text
          Expanded(
            child: Text(
              verse.text,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: verseFontSize,
                height: 1.8,
                color: verseColor,
              ),
            ),
          ),
          
          // Popup Action Trigger
          PopupMenuButton<String>(
            tooltip: 'Verse actions',
            onSelected: (value) {
              if (value == 'bookmark') onToggleBookmark();
              if (value == 'highlight') onChooseHighlight();
              if (value == 'share') onShare();
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                value: 'bookmark',
                child: Row(
                  children: [
                    Icon(
                      isBookmarked
                          ? Icons.bookmark_remove_rounded
                          : Icons.bookmark_add_rounded,
                      size: 18,
                      color: isDark ? AppColors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(isBookmarked ? 'Remove bookmark' : 'Bookmark verse'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'highlight',
                child: Row(
                  children: [
                    Icon(Icons.highlight_rounded,
                        size: 18, color: isDark ? AppColors.white : AppColors.primary),
                    const SizedBox(width: 10),
                    const Text('Highlight color'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.ios_share_rounded,
                        size: 18, color: isDark ? AppColors.white : AppColors.primary),
                    const SizedBox(width: 10),
                    const Text('Share card'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 2),
              child: Icon(
                isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.more_horiz_rounded,
                size: 20,
                color: isBookmarked
                    ? (isDark ? AppColors.white : AppColors.primary)
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
