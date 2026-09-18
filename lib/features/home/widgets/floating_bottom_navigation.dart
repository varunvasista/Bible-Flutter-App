import 'package:flutter/material.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class FloatingBottomNavigation extends StatelessWidget {
  const FloatingBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavigationItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
      ),
      _NavigationItemData(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book_rounded,
        label: 'Bible',
      ),
      _NavigationItemData(
        icon: Icons.edit_note_outlined,
        activeIcon: Icons.edit_note_rounded,
        label: 'Notes',
      ),
      _NavigationItemData(
        icon: Icons.music_note,
        activeIcon: Icons.music_note_rounded,
        label: 'Hymns',
      ),
      _NavigationItemData(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
            color: isDark ? AppColors.kyrieDarkGrey : AppColors.border,
            width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppColors.darkGray
                                : AppColors.borderLight)
                            : AppColors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected
                            ? (isDark ? AppColors.white : AppColors.primary)
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? AppColors.white : AppColors.primary)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavigationItemData {
  const _NavigationItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
