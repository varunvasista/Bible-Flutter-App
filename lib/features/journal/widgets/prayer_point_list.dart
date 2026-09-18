import 'package:flutter/material.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Renders a horizontal list of prayer cards.
class PrayerPointList extends StatelessWidget {
  const PrayerPointList({super.key, required this.prayers});

  final List<String> prayers;

  void _showAllPrayersBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Prayer Points',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.border),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    itemCount: prayers.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: AppColors.border,
                      height: 24,
                    ),
                    itemBuilder: (context, index) {
                      final prayer = prayers[index];
                      final IconData icon;
                      final Color iconColor;
                      final String title;

                      if (index == 0) {
                        title = 'Family Health';
                        icon = Icons.favorite_rounded;
                        iconColor = AppColors.primary;
                      } else if (index == 1) {
                        title = 'Career Guidance';
                        icon = Icons.work_rounded;
                        iconColor = AppColors.primary;
                      } else {
                        title = 'Daily Devotion';
                        icon = Icons.volunteer_activism_rounded;
                        iconColor = AppColors.primary;
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.lightMint,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: iconColor,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 14),
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
                                const SizedBox(height: 4),
                                Text(
                                  prayer,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (prayers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PRAYER POINTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: () {
                  _showAllPrayersBottomSheet(context);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: prayers.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final text = prayers[index];
              return _PrayerPointCard(index: index, text: text);
            },
          ),
        ),
      ],
    );
  }
}

class _PrayerPointCard extends StatelessWidget {
  const _PrayerPointCard({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    // Determine styling and info based on index
    final String title;
    final IconData icon;
    final Color iconColor;
    final Widget statusChip;

    if (index == 0) {
      title = 'Family Health';
      icon = Icons.favorite_rounded;
      iconColor = AppColors.primary;
      statusChip = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.lightMint,
          borderRadius: BorderRadius.circular(12),
        ),
        // child: const Text(
        //   '12 Supporters',
        //   style: TextStyle(
        //     color: AppColors.primary,
        //     fontSize: 10,
        //     fontWeight: FontWeight.w700,
        //   ),
        // ),
      );
    } else if (index == 1) {
      title = 'Career Guidance';
      icon = Icons.work_rounded;
      iconColor = AppColors.primary;
      statusChip = const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container(
          //   width: 6,
          //   height: 6,
          //   decoration: const BoxDecoration(
          //     color: AppColors.error,
          //     shape: BoxShape.circle,
          //   ),
          // ),
          // const SizedBox(width: 5),
          // const Text(
          //   'Urgent',
          //   style: TextStyle(
          //     color: AppColors.error,
          //     fontSize: 10,
          //     fontWeight: FontWeight.w700,
          //   ),
          // ),
        ],
      );
    } else {
      title = 'Daily Devotion';
      icon = Icons.volunteer_activism_rounded;
      iconColor = AppColors.primary;
      statusChip = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(12),
        ),
        // child: const Text(
        //   'Active',
        //   style: TextStyle(
        //     color: AppColors.textPrimary,
        //     fontSize: 10,
        //     fontWeight: FontWeight.w700,
        //   ),
        // ),
      );
    }

    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
