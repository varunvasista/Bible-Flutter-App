import 'package:flutter/material.dart';
import '../../reading_plan/services/reading_plan_service.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class ReadingPlanProgressCard extends StatelessWidget {
  const ReadingPlanProgressCard({
    super.key,
    required this.plan,
    required this.completedDays,
    required this.todayAssignment,
  });

  final ReadingPlan plan;
  final int completedDays;
  final ReadingPlanDay todayAssignment;

  @override
  Widget build(BuildContext context) {
    final progress = plan.totalDays == 0 ? 0.0 : completedDays / plan.totalDays;
    final percent = (progress * 100).toInt();

    final first = todayAssignment.readings.first;
    final last = todayAssignment.readings.last;
    final readingSummary = todayAssignment.readings.length == 1
        ? '${first.book} ${first.chapter}'
        : '${first.book} ${first.chapter} to ${last.book} ${last.chapter}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Day ${todayAssignment.day} of ${plan.totalDays} • $readingSummary',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Progress updates as you read',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Circular progress indicator
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: AppColors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
