import 'package:flutter/material.dart';

import '../models/journal_entry.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Displays a single [JournalEntry] as a summary card.
class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({super.key, required this.entry});

  final JournalEntry entry;

  String _getCategory(String text) {
    final t = text.toLowerCase();
    if (t.contains('pray') || t.contains('prayer')) return 'Prayer';
    if (t.contains('study') || t.contains('scripture') || t.contains('bible') || t.contains('verse')) return 'Study';
    return 'Reflection';
  }

  String _getTitle(String text) {
    final firstLine = text.split('\n').first.trim();
    if (firstLine.length <= 40) return firstLine;
    final words = firstLine.split(' ');
    if (words.length <= 6) return firstLine;
    return '${words.take(6).join(' ')}...';
  }

  String _getPreview(String text) {
    final title = _getTitle(text);
    if (text.startsWith(title)) {
      final remaining = text.substring(title.length).trim();
      return remaining.isNotEmpty ? remaining : text;
    }
    return text;
  }

  String _formatDate(String dateKey) {
    try {
      final date = DateTime.parse(dateKey);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = _getCategory(entry.text);
    final title = _getTitle(entry.text);
    final preview = _getPreview(entry.text);
    final dateStr = _formatDate(entry.dateKey);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.kyrieDarkGrey : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkGray : AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: () {
              // Tapping note opens details
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Category chip + Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkGray : AppColors.lightMint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.white : AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.white : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Preview text
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  
                  // Emotion badges
                  if (entry.detectedEmotions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: entry.detectedEmotions.take(3).map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkGray : AppColors.borderLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.white : AppColors.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
