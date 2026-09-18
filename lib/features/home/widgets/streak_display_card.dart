import 'package:flutter/material.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class StreakDisplayCard extends StatelessWidget {
  const StreakDisplayCard({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final ratio = (streak / 30).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 3,
                  backgroundColor: AppColors.offWhite,
                  color: AppColors.black,
                ),
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.black,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reading Streak',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$streak day${streak == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Keep going',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}
