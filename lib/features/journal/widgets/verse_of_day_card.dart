import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/verse_of_day.dart';
import 'package:bible_app/core/theme/app_colors.dart';
import 'package:bible_app/core/services/service_locator.dart';

/// Displays the day's verse suggestion with its reference.
class VerseOfDayCard extends StatelessWidget {
  const VerseOfDayCard({super.key, required this.verse});

  final VerseOfDay verse;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VERSE OF THE DAY',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(
                Icons.auto_awesome,
                color: AppColors.white.withOpacity(0.6),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Verse text
          Text(
            '"${verse.cleanText}"',
            style: TextStyle(
              color: AppColors.white,
              fontSize: accessibilityService.largeVerseText ? 24 : 18,
              height: 1.5,
              fontStyle: FontStyle.italic,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 16),
          // Reference and action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  verse.reference,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  _CircularActionButton(
                    icon: Icons.share_rounded,
                    onPressed: () {
                      Share.share(
                          '"${verse.cleanText}" — ${verse.reference}\n\n@AdventBible');
                    },
                  ),
                  const SizedBox(width: 8),
                  _CircularActionButton(
                    icon: Icons.copy_all_rounded,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: '"${verse.cleanText}" — ${verse.reference}',
                      )).then((_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Verse copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularActionButton extends StatelessWidget {
  const _CircularActionButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: AppColors.white),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}
