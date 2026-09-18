import 'package:flutter/material.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Placeholder for the Journal feature (Step 4).
class JournalPlaceholderScreen extends StatelessWidget {
  const JournalPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        title: const Text(
          'Journal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? AppColors.kyrieDarkGrey : AppColors.borderLight,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? AppColors.darkGray : AppColors.borderDark, width: 2),
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: 52,
                color: isDark ? AppColors.white : AppColors.black,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Journal',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming in Step 4.',
              style: TextStyle(fontSize: 15, color: AppColors.disabledGrey),
            ),
            const SizedBox(height: 4),
            const Text(
              'Write and save your personal reflections.',
              style: TextStyle(fontSize: 13, color: AppColors.disabledGrey),
            ),
          ],
        ),
      ),
    );
  }
}
