import 'package:flutter/material.dart';

import '../../../core/services/service_locator.dart';
import '../widgets/book_list_tile.dart';
import 'chapter_list_screen.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Scrollable list of all books within a testament.
class BookListScreen extends StatelessWidget {
  const BookListScreen({
    super.key,
    required this.translation,
    required this.testamentName,
  });

  final String translation;
  final String testamentName;

  @override
  Widget build(BuildContext context) {
    final books = bibleRepo.getBooks(translation, testamentName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        title: Text(
          testamentName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Container(
            color: AppColors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              '${books.length} books · $translation',
              style: const TextStyle(
                color: AppColors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (_, i) {
          final book = books[i];
          return BookListTile(
            bookName: book.name,
            chapterCount: book.chapters.length,
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.transparent,
                builder: (_) => ChapterListScreen(
                  translation: translation,
                  bookName: book.name,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
