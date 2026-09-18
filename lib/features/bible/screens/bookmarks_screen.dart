import 'package:flutter/material.dart';

import '../../../core/services/service_locator.dart';
import '../../../data/models/bible_verse.dart';
import 'verse_reader_screen.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late List<BibleVerse> _bookmarks;

  @override
  void initState() {
    super.initState();
    _bookmarks = bookmarkService.getBookmarks();
  }

  Future<void> _remove(BibleVerse verse) async {
    await bookmarkService.removeBookmark(verse);
    if (!mounted) return;
    setState(() {
      _bookmarks = bookmarkService.getBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Bookmarks',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.primary,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
            
            // Content List / Empty State
            Expanded(
              child: _bookmarks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Circular Icon Container
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.kyrieDarkGrey : AppColors.lightMint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bookmark_border_rounded,
                              color: AppColors.textSecondary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Title
                           Text(
                            'No bookmarks yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.white : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Description
                          const SizedBox(
                            width: 260,
                            child: Text(
                              'Start exploring scripture and save your favorite verses to see them here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Primary Button
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              child: const Text(
                                'Browse Bookmarks',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 60), // Offset empty space to balance layout
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _bookmarks.length,
                      itemBuilder: (context, i) {
                        final v = _bookmarks[i];
                        final ref = '${v.book} ${v.chapter}:${v.verse}';
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(color: isDark ? AppColors.kyrieDarkGrey : AppColors.border, width: 1),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              if (v.translation == null ||
                                  v.book == null ||
                                  v.chapter == null) {
                                return;
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => VerseReaderScreen(
                                    translation: v.translation!,
                                    bookName: v.book!,
                                    initialChapter: v.chapter!,
                                    initialVerse: v.verse,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        ref,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.white : AppColors.primary,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          if (v.translation != null) ...[
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isDark ? AppColors.kyrieDarkGrey : AppColors.lightMint,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  v.translation!.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDark ? AppColors.white : AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                          ],
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: AppColors.textSecondary,
                                              size: 20,
                                            ),
                                            onPressed: () => _remove(v),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    v.text,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textSecondary,
                                      height: 1.45,
                                    ),
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
