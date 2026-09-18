import 'package:flutter/material.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Card used to export/share a verse image.
class VerseShareCard extends StatelessWidget {
  const VerseShareCard({
    super.key,
    required this.reference,
    required this.text,
    required this.translation,
    this.backgroundColor = AppColors.black,
  });

  final String reference;
  final String text;
  final String translation;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              backgroundColor,
              Color.alphaBlend(AppColors.black.withValues(alpha: 0.18), backgroundColor),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reference,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Text(
                '"$text"',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              translation,
              style: const TextStyle(
                color: AppColors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
