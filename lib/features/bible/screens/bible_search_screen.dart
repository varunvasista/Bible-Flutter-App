import 'package:flutter/material.dart';

import '../../../data/models/bible_verse.dart';
import '../services/bible_search_service.dart';
import 'verse_reader_screen.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class BibleSearchScreen extends StatefulWidget {
  const BibleSearchScreen({super.key, required this.searchService});

  final BibleSearchService searchService;

  @override
  State<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends State<BibleSearchScreen> {
  final _controller = TextEditingController();
  List<BibleVerse> _results = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runSearch() {
    setState(() {
      _results = widget.searchService.searchVerses(_controller.text);
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
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Search for Translation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: isDark ? AppColors.kyrieDarkGrey : AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _runSearch(),
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? AppColors.white : AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search scriptures, topics, or notes...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        color: isDark ? AppColors.white : AppColors.primary,
                      ),
                      onPressed: _runSearch,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),

            // Results Area / Empty State
            Expanded(
              child: _results.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          '"Ask, and it will be given to you;\nseek, and you will find;\nknock, and it will be opened to you."',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Georgia',
                            fontSize: 18,
                            color: AppColors.grey,
                            height: 1.6,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _results.length,
                      itemBuilder: (context, i) {
                        final v = _results[i];
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
                                      if (v.translation != null)
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
