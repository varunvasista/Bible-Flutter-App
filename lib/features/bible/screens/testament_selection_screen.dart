import 'package:flutter/material.dart';

import '../../../core/services/service_locator.dart';
import 'bookmarks_screen.dart';
import 'chapter_list_screen.dart';
import 'translation_selection_screen.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Shows a reading-focused Bible Books screen with search and testament toggles.
class TestamentSelectionScreen extends StatefulWidget {
  const TestamentSelectionScreen({super.key, required this.translation});

  final String translation;

  @override
  State<TestamentSelectionScreen> createState() =>
      _TestamentSelectionScreenState();
}

class _TestamentSelectionScreenState extends State<TestamentSelectionScreen> {
  int _selectedTestamentIndex = 0; // 0 = Old Testament, 1 = New Testament
  String _searchQuery = '';

  String _getFirstLetter(String name) {
    if (name.isEmpty) return '';
    final cleanName = name.replaceAll(RegExp(r'^[0-9]\s*'), '');
    if (cleanName.isEmpty) return name[0].toUpperCase();
    return cleanName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final testaments = bibleRepo.getTestaments(widget.translation);
    
    if (testaments.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final oldTestament = testaments.firstWhere(
      (t) => t.name.toLowerCase().contains('old'),
      orElse: () => testaments.first,
    );
    final newTestament = testaments.firstWhere(
      (t) => t.name.toLowerCase().contains('new'),
      orElse: () => testaments.last,
    );

    final activeTestamentBooks = _selectedTestamentIndex == 0
        ? oldTestament.books
        : newTestament.books;

    final filteredBooks = activeTestamentBooks.where((book) {
      if (_searchQuery.isEmpty) return true;
      return book.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.translation,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.white : AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Bookmarks',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
              );
            },
            icon: Icon(Icons.bookmark_border_rounded, color: isDark ? AppColors.white : AppColors.primary, size: 22),
          ),
          IconButton(
            tooltip: 'Change Translation',
            icon: Icon(Icons.translate_rounded, color: isDark ? AppColors.white : AppColors.primary, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TranslationSelectionScreen(isChangeTranslation: true),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SizedBox(
                height: 52,
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? AppColors.white : AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search for a book...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.kyrieDarkGrey : AppColors.borderLight,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            
            // Testament Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkGray : AppColors.greyLightest,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTestamentIndex = 0;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _selectedTestamentIndex == 0 ? (isDark ? AppColors.kyrieDarkGrey : AppColors.white) : AppColors.transparent,
                            borderRadius: BorderRadius.circular(21),
                            boxShadow: _selectedTestamentIndex == 0
                                ? [
                                    BoxShadow(
                                      color: AppColors.black.withOpacity(0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Old Testament',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: _selectedTestamentIndex == 0 ? FontWeight.w600 : FontWeight.w500,
                              color: _selectedTestamentIndex == 0 ? (isDark ? AppColors.white : AppColors.primary) : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTestamentIndex = 1;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _selectedTestamentIndex == 1 ? (isDark ? AppColors.kyrieDarkGrey : AppColors.white) : AppColors.transparent,
                            borderRadius: BorderRadius.circular(21),
                            boxShadow: _selectedTestamentIndex == 1
                                ? [
                                    BoxShadow(
                                      color: AppColors.black.withOpacity(0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'New Testament',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: _selectedTestamentIndex == 1 ? FontWeight.w600 : FontWeight.w500,
                              color: _selectedTestamentIndex == 1 ? (isDark ? AppColors.white : AppColors.primary) : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),

            // Scrollable Books List
            Expanded(
              child: filteredBooks.isEmpty
                  ? const Center(
                      child: Text(
                        'No books found',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
                        final bookLetter = _getFirstLetter(book.name);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          color: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: const BorderSide(color: AppColors.border, width: 1),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () {
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: AppColors.transparent,
                                builder: (_) => ChapterListScreen(
                                  translation: widget.translation,
                                  bookName: book.name,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  // Left mint icon
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: AppColors.lightMint,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      bookLetter,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Center book name + chapters
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          book.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${book.chapters.length} Chapters',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Right chevron
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textSecondary,
                                    size: 24,
                                  ),
                                ],
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
  }
}

