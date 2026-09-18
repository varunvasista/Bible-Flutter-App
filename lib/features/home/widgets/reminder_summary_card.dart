import 'package:flutter/material.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class ReminderSummaryCard extends StatelessWidget {
  const ReminderSummaryCard({
    super.key,
    required this.bibleReminderEnabled,
    required this.bibleReminderTime,
    required this.prayerReminderEnabled,
    required this.prayerReminderTime,
    required this.onOpenPlanReading,
    required this.onOpenJournal,
    required this.onOpenSettings,
  });

  final bool bibleReminderEnabled;
  final TimeOfDay bibleReminderTime;
  final bool prayerReminderEnabled;
  final TimeOfDay prayerReminderTime;
  final VoidCallback onOpenPlanReading;
  final VoidCallback onOpenJournal;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reminder Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onOpenSettings,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ReminderItem(
            icon: Icons.menu_book_rounded,
            title: 'Bible Reading',
            subtitle: 'DAILY DEVOTION',
            enabled: bibleReminderEnabled,
            time: bibleReminderTime,
          ),
          const Divider(color: AppColors.border, height: 20, thickness: 1),
          ReminderItem(
            icon: Icons.volunteer_activism_rounded,
            title: 'Prayer',
            subtitle: 'MORNING GRACE',
            enabled: prayerReminderEnabled,
            time: prayerReminderTime,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: onOpenPlanReading,
                    icon: const Icon(Icons.bookmark_outline, size: 18),
                    label: const Text(
                      "Today's Plan",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onOpenJournal,
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text(
                      "Open Notes",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(
                Icons.settings_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              label: const Text(
                'Edit Reminders',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderItem extends StatelessWidget {
  const ReminderItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final TimeOfDay time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.lightMint,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: enabled ? AppColors.lightMint : AppColors.border,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            enabled ? time.format(context) : 'Off',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color:
                  enabled ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
