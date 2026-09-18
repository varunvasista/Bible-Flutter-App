import 'package:flutter/material.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// List tile for a Bible translation on [TranslationSelectionScreen].
///
/// Shows the short code (e.g. "KJV"), the full name, a "Ready" badge when the
/// translation is already loaded, or a spinner when it is being loaded.
class TranslationTile extends StatelessWidget {
  const TranslationTile({
    super.key,
    required this.translationCode,
    required this.fullName,
    required this.isLoaded,
    required this.isLoading,
    required this.onTap,
  });

  final String translationCode;
  final String fullName;
  final bool isLoaded;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      elevation: 0,
      shadowColor: AppColors.transparent,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.kyrieDarkGrey : AppColors.borderDark,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              // Coloured abbreviation circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkGray : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    translationCode,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name + status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? AppColors.white : AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isLoaded && !isLoading)
                      const Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 13, color: AppColors.greenShade600),
                          SizedBox(width: 4),
                          Text(
                            'Ready to read',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.greenShade700,
                            ),
                          ),
                        ],
                      )
                    else if (!isLoading)
                      const Text(
                        'Tap to load',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              // Right action
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.disabledGrey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
