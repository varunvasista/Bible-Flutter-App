import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/service_locator.dart';
import '../../../data/models/bible_verse.dart';
import '../../reading_plan/services/reading_plan_service.dart';
import '../services/highlight_service.dart';
import '../widgets/verse_share_card.dart';
import '../widgets/verse_tile.dart';
import 'bible_search_screen.dart';
import 'testament_selection_screen.dart';
import 'translation_selection_screen.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class VerseReaderScreen extends StatefulWidget {
  const VerseReaderScreen({
    super.key,
    required this.translation,
    required this.bookName,
    required this.initialChapter,
    this.initialVerse,
  });

  final String translation;
  final String bookName;
  final int initialChapter;
  final int? initialVerse;

  @override
  State<VerseReaderScreen> createState() => _VerseReaderScreenState();
}

class _VerseReaderScreenState extends State<VerseReaderScreen> {
  late int _chapter;
  late List<int> _chapterNums;
  ReadingPlanDay? _todayAssignment;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};

  @override
  void initState() {
    super.initState();
    _chapter = widget.initialChapter;
    _chapterNums =
        bibleRepo.getChapterNumbers(widget.translation, widget.bookName);
    _loadTodayAssignment();
    _saveReadingProgress();
    bibleCacheService.prefetchAdjacentChapters(
      widget.translation,
      widget.bookName,
      _chapter,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialVerse != null) {
        _scrollToVerse(widget.initialVerse!);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _hasPrev => _chapterNums.isNotEmpty && _chapter > _chapterNums.first;

  bool get _hasNext => _chapterNums.isNotEmpty && _chapter < _chapterNums.last;

  Future<void> _loadTodayAssignment() async {
    final assignment = await readingPlanService.getTodayAssignment();
    if (!mounted) return;
    setState(() => _todayAssignment = assignment);
  }

  String _readingSummary(ReadingPlanDay assignment) {
    final first = assignment.readings.first;
    final last = assignment.readings.last;
    return assignment.readings.length == 1
        ? '${first.book} ${first.chapter}'
        : '${first.book} ${first.chapter} to ${last.book} ${last.chapter}';
  }

  void _navigate(int newChapter) {
    setState(() {
      _chapter = newChapter;
      _verseKeys.clear();
    });
    _saveReadingProgress();
    bibleCacheService.prefetchAdjacentChapters(
      widget.translation,
      widget.bookName,
      _chapter,
    );
    _scrollController.jumpTo(0);
  }

  void _saveReadingProgress() {
    readingProgressService.saveProgress(
      widget.translation,
      widget.bookName,
      _chapter,
    );
    readingPlanService.updateProgressForReading(
      book: widget.bookName,
      chapter: _chapter,
    );
  }

  void _goPrev() {
    final idx = _chapterNums.indexOf(_chapter);
    if (idx > 0) _navigate(_chapterNums[idx - 1]);
  }

  void _goNext() {
    final idx = _chapterNums.indexOf(_chapter);
    if (idx >= 0 && idx < _chapterNums.length - 1) {
      _navigate(_chapterNums[idx + 1]);
    }
  }

  BibleVerse _withContext(BibleVerse verse) {
    return BibleVerse(
      translation: widget.translation,
      book: widget.bookName,
      chapter: _chapter,
      verse: verse.verse,
      text: verse.text,
    );
  }

  Future<void> _toggleBookmark(BibleVerse verse) async {
    final item = _withContext(verse);
    await bookmarkService.toggleBookmark(item);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _chooseHighlight(BibleVerse verse) async {
    final item = _withContext(verse);
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => _HighlightPickerSheet(
          current: highlightService.getHighlightColor(item)),
    );

    if (selected == null) return;
    if (selected == 'clear') {
      await highlightService.removeHighlight(item);
    } else {
      final color = HighlightService.supportedColors[selected];
      if (color != null) {
        await highlightService.highlightVerse(item, color);
      }
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openShareDialog(BibleVerse verse) async {
    final item = _withContext(verse);
    final reference = '${item.book} ${item.chapter}:${item.verse}';

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _ShareVerseDialog(
        reference: reference,
        text: item.text,
        translation: item.translation ?? widget.translation,
      ),
    );
  }

  void _scrollToVerse(int verseNumber) {
    final key = _verseKeys[verseNumber];
    final ctx = key?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      alignment: 0.15,
    );
  }

  @override
  Widget build(BuildContext context) {
    final verses = bibleCacheService.getChapterVerses(
        widget.translation, widget.bookName, _chapter);

    final themeText =
        (widget.bookName.toUpperCase() == 'PSALMS' && _chapter == 23)
            ? 'THE LORD IS MY SHEPHERD'
            : '${widget.bookName.toUpperCase()} CHAPTER $_chapter';

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
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TestamentSelectionScreen(
                      translation: widget.translation,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.bookName} $_chapter',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: isDark ? AppColors.white : AppColors.primary,
                    size: 22,
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TranslationSelectionScreen(),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.kyrieDarkGrey : AppColors.lightMint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.translation.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: isDark ? AppColors.white : AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.primary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BibleSearchScreen(
                    searchService: bibleSearchService,
                  ),
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
            if (_todayAssignment != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Today's reading: ${_readingSummary(_todayAssignment!)}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: verses.isEmpty ? 1 : verses.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.lightMint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            themeText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Center(
                        child: Text(
                          'Chapter $_chapter',
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  }

                  if (verses.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No verses found.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }

                  final v = verses[index - 2];
                  final data = _withContext(v);
                  _verseKeys.putIfAbsent(v.verse, () => GlobalKey());

                  return Container(
                    key: _verseKeys[v.verse],
                    child: VerseTile(
                      verse: v,
                      translation: widget.translation,
                      bookName: widget.bookName,
                      chapterNumber: _chapter,
                      highlightColor: highlightService.getHighlightColor(data),
                      isBookmarked: bookmarkService.isBookmarked(data),
                      onToggleBookmark: () => _toggleBookmark(v),
                      onChooseHighlight: () => _chooseHighlight(v),
                      onShare: () => _openShareDialog(v),
                      fontScale: accessibilityService.fontScale,
                      highContrast: accessibilityService.highContrast,
                      largeVerseText: accessibilityService.largeVerseText,
                    ),
                  );
                },
              ),
            ),
            _ChapterNavBar(
              chapterNumber: _chapter,
              chapterNums: _chapterNums,
              hasPrev: _hasPrev,
              hasNext: _hasNext,
              onPrev: _goPrev,
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightPickerSheet extends StatelessWidget {
  const _HighlightPickerSheet({this.current});

  final Color? current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Highlight color',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: HighlightService.supportedColors.entries.map((entry) {
                final isCurrent = current?.toARGB32() == entry.value.toARGB32();
                return ChoiceChip(
                  selected: isCurrent,
                  label: Text(entry.key),
                  backgroundColor: entry.value,
                  selectedColor: entry.value,
                  labelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => Navigator.of(context).pop(entry.key),
                );
              }).toList(growable: false),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop('clear'),
              icon: const Icon(Icons.layers_clear_rounded,
                  color: AppColors.primary),
              label: const Text('Clear highlight',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareVerseDialog extends StatefulWidget {
  const _ShareVerseDialog({
    required this.reference,
    required this.text,
    required this.translation,
  });

  final String reference;
  final String text;
  final String translation;

  @override
  State<_ShareVerseDialog> createState() => _ShareVerseDialogState();
}

class _ShareVerseDialogState extends State<_ShareVerseDialog> {
  final _cardKey = GlobalKey();
  bool _busy = false;

  Future<void> _saveImage() async {
    setState(() => _busy = true);
    try {
      final bytes = await _capturePng(_cardKey);
      if (bytes == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/verse_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved image to ${file.path}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareImage() async {
    setState(() => _busy = true);
    try {
      final bytes = await _capturePng(_cardKey);
      if (bytes == null) return;
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/verse_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: widget.reference,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Uint8List?> _capturePng(GlobalKey key) async {
    await Future.delayed(const Duration(milliseconds: 20));
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: _cardKey,
              child: VerseShareCard(
                reference: widget.reference,
                text: widget.text,
                translation: widget.translation,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _saveImage,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Save image'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _shareImage,
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterNavBar extends StatelessWidget {
  const _ChapterNavBar({
    required this.chapterNumber,
    required this.chapterNums,
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext,
  });

  final int chapterNumber;
  final List<int> chapterNums;
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final idx = chapterNums.indexOf(chapterNumber);
    final prevChapter = (hasPrev && idx > 0) ? chapterNums[idx - 1] : null;
    final nextChapter = (hasNext && idx >= 0 && idx < chapterNums.length - 1)
        ? chapterNums[idx + 1]
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(color: AppColors.greyLightest, height: 1),
        Container(
          color: AppColors.white,
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Previous Chapter
              if (hasPrev && prevChapter != null)
                GestureDetector(
                  onTap: onPrev,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.borderLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chapter $prevChapter',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(width: 80),

              // Right: Next Chapter
              if (hasNext && nextChapter != null)
                GestureDetector(
                  onTap: onNext,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.borderLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chapter $nextChapter',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(width: 80),
            ],
          ),
        ),
      ],
    );
  }
}
