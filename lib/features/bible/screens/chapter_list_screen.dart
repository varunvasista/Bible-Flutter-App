import 'package:flutter/material.dart';

import '../../../core/services/service_locator.dart';
import 'verse_reader_screen.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Displays all chapter numbers for a book in a draggable modal bottom sheet.
class ChapterListScreen extends StatefulWidget {
  const ChapterListScreen({
    super.key,
    required this.translation,
    required this.bookName,
  });

  final String translation;
  final String bookName;

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> {
  int? _currentReadingChapter;

  @override
  void initState() {
    super.initState();
    _loadCurrentProgress();
  }

  Future<void> _loadCurrentProgress() async {
    final position = await readingProgressService.getLastReadingPosition();
    if (position != null &&
        position.book.toLowerCase() == widget.bookName.toLowerCase() &&
        position.translation.toLowerCase() == widget.translation.toLowerCase()) {
      if (mounted) {
        setState(() {
          _currentReadingChapter = position.chapter;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapterNums = bibleRepo.getChapterNumbers(widget.translation, widget.bookName);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [
              BoxShadow(
                color: AppColors.black12,
                blurRadius: 10,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.kyrieDarkGrey : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Fixed Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.bookName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.white : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Select a Chapter',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.kyrieDarkGrey : AppColors.offWhite,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.transparent, height: 1),

                // Scrollable Grid
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: chapterNums.length,
                    itemBuilder: (context, i) {
                      final num = chapterNums[i];
                      final isSelected = num == _currentReadingChapter;

                      return Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.white : AppColors.primary)
                                : (isDark ? AppColors.darkGray : AppColors.grayBackground),
                            shape: BoxShape.circle,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: (isDark ? AppColors.white : AppColors.primary).withOpacity(0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Material(
                            color: AppColors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => VerseReaderScreen(
                                      translation: widget.translation,
                                      bookName: widget.bookName,
                                      initialChapter: num,
                                    ),
                                  ),
                                );
                              },
                              customBorder: const CircleBorder(),
                              child: Center(
                                  child: Text(
                                    num.toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? (isDark ? AppColors.black : AppColors.white)
                                          : (isDark ? AppColors.white : AppColors.neutralDark),
                                    ),
                                  ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
