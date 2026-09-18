import 'package:flutter/material.dart';

import '../../../ai/services/journal_reflection_service.dart';
import '../../../core/services/service_locator.dart';
import '../models/journal_entry.dart';
import '../widgets/journal_entry_card.dart';
import 'reflection_editor_screen.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isAnalyzing = false;
  JournalReflectionResult? _lastReflection;
  List<JournalEntry> _entries = [];
  int _streakDays = 0;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _loadStreak();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadEntries() {
    setState(() {
      _entries = journalRepo.getAllEntries();
    });
  }

  Future<void> _loadStreak() async {
    await streakService.loadCurrentStreak();
    setState(() {
      _streakDays = streakService.getCurrentStreak();
    });
  }

  Future<void> _saveEntry() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;


    final emotions = emotionDetectionService.detectEmotions(text);
    final now = DateTime.now();
    final entry = JournalEntry(
      id: now.millisecondsSinceEpoch.toString(),
      dateKey: now.toIso8601String().substring(0, 10),
      text: text,
      detectedEmotions: emotions,
      createdAt: now,
    );

    await journalRepo.saveEntry(entry);

    // Notify TodayScreen to refresh.
    journalRefreshNotifier.value++;

    _controller.clear();
    _focusNode.unfocus();

    _loadEntries();
    await _loadStreak();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved — emotions detected: ${emotions.join(', ')}',
            style: const TextStyle(fontSize: 13),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Start reflection analysis in background; shows prayer points when ready
    _analyzeForPrayer(text);
  }

  Future<void> _analyzeForPrayer(String text) async {
    setState(() {
      _isAnalyzing = true;
      _lastReflection = null;
    });
    try {
      final result = await journalReflectionService.analyzeEntry(text);
      if (!mounted) return;
      setState(() {
        _lastReflection = result;
        _isAnalyzing = false;
      });
      _showPrayerSheet(result);
    } catch (_) {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _showPrayerSheet(JournalReflectionResult result) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _PrayerPointsSheet(reflection: result),
    );
  }

  void _openWriteScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReflectionEditorScreen(
          onSave: (title, content, tags) async {
            var fullText = '';
            if (title.isNotEmpty) {
              fullText += '$title\n';
            }
            fullText += content;
            if (tags.isNotEmpty) {
              fullText += '\n\nTags: ${tags.join(', ')}';
            }
            _controller.text = fullText;
            await _saveEntry();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _entries;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Notes',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.white : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Reflect on your spiritual journey and quiet moments.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),


              // 3. Featured Reflection Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Banner Top Section
                      const ReflectionBanner(),
                      
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'Begin your reflection',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Capture your thoughts on today's word. Your sanctuary of quiet wisdom starts with a single sentence.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.slateGray,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: FilledButton(
                                onPressed: _openWriteScreen,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text(
                                  'Write Now',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Today's Prompt Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.creamBackground,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "TODAY'S PROMPT",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '"Where did you experience His kindness today?"',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Journaling Streak',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '$_streakDays Days',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _streakDays == 0 ? 0.0 : (_streakDays % 30) / 30.0,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Saved Reflections Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Saved Reflections',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        if (_isAnalyzing) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        if (_lastReflection != null) ...[
                          TextButton.icon(
                            onPressed: () => _showPrayerSheet(_lastReflection!),
                            icon: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                            label: const Text(
                              'Prayer Points',
                              style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        TextButton(
                          onPressed: () {
                            _loadEntries();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 6. Reflections List
              if (filtered.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return JournalEntryCard(entry: filtered[index]);
                  },
                ),

              // Bottom clearance spacing for floating navigation bar
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerPointsSheet extends StatelessWidget {
  const _PrayerPointsSheet({required this.reflection});

  final JournalReflectionResult reflection;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Prayer Points',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: AppColors.black),
            ),
            if (reflection.emotions.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Detected: ${reflection.emotions.join(', ')}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 16),
            ...List.generate(
                reflection.prayerPoints.length,
                (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                  color: AppColors.white, fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reflection.prayerPoints[i],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
            if (reflection.verses.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Scriptures',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black),
              ),
              const SizedBox(height: 8),
              ...reflection.verses.map(
                (v) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.reference,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        v.text,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ReflectionBanner extends StatelessWidget {
  const ReflectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _BannerPainter(),
      ),
    );
  }
}

class _BannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Background Gradient (White to Light Gray)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.white, AppColors.lightMint],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Soft Wavy Shapes (Grayscale waves)
    final wavePaint1 = Paint()
      ..color = AppColors.greyLight.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..cubicTo(
        size.width * 0.3, size.height * 0.2,
        size.width * 0.7, size.height * 0.8,
        size.width, size.height * 0.5,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, wavePaint1);

    final wavePaint2 = Paint()
      ..color = AppColors.grayPlaceholder.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..cubicTo(
        size.width * 0.4, size.height * 0.9,
        size.width * 0.6, size.height * 0.3,
        size.width, size.height * 0.6,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, wavePaint2);

    // 3. Glowing Light (Radial Gradient behind the book)
    final center = Offset(size.width / 2, size.height * 0.65);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.white.withOpacity(0.8),
          AppColors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 60));
    canvas.drawCircle(center, 60, glowPaint);

    // 4. Open Book Pages
    final bookHeight = size.height * 0.35;
    final bookWidth = size.width * 0.36;
    final bookLeft = center.dx - bookWidth / 2;
    final bookTop = center.dy - bookHeight / 2;

    final pagePaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Draw book shadow/cover backing
    final coverPath = Path()
      ..moveTo(bookLeft - 4, bookTop + bookHeight * 0.85)
      ..quadraticBezierTo(
        center.dx, bookTop + bookHeight * 1.05,
        bookLeft + bookWidth + 4, bookTop + bookHeight * 0.85,
      )
      ..lineTo(bookLeft + bookWidth + 2, bookTop + bookHeight * 0.35)
      ..quadraticBezierTo(
        center.dx, bookTop + bookHeight * 0.55,
        bookLeft - 2, bookTop + bookHeight * 0.35,
      )
      ..close();
    canvas.drawPath(coverPath, shadowPaint);

    // Draw Left Page
    final leftPage = Path()
      ..moveTo(center.dx, bookTop + bookHeight * 0.5)
      ..cubicTo(
        center.dx - bookWidth * 0.2, bookTop + bookHeight * 0.2,
        bookLeft + bookWidth * 0.1, bookTop + bookHeight * 0.25,
        bookLeft, bookTop + bookHeight * 0.3,
      )
      ..lineTo(bookLeft, bookTop + bookHeight * 0.85)
      ..cubicTo(
        bookLeft + bookWidth * 0.1, bookTop + bookHeight * 0.8,
        center.dx - bookWidth * 0.2, bookTop + bookHeight * 0.75,
        center.dx, bookTop + bookHeight * 0.95,
      )
      ..close();
    canvas.drawPath(leftPage, pagePaint);

    // Draw Right Page
    final rightPage = Path()
      ..moveTo(center.dx, bookTop + bookHeight * 0.5)
      ..cubicTo(
        center.dx + bookWidth * 0.2, bookTop + bookHeight * 0.2,
        bookLeft + bookWidth * 0.9, bookTop + bookHeight * 0.25,
        bookLeft + bookWidth, bookTop + bookHeight * 0.3,
      )
      ..lineTo(bookLeft + bookWidth, bookTop + bookHeight * 0.85)
      ..cubicTo(
        bookLeft + bookWidth * 0.9, bookTop + bookHeight * 0.8,
        center.dx + bookWidth * 0.2, bookTop + bookHeight * 0.75,
        center.dx, bookTop + bookHeight * 0.95,
      )
      ..close();
    canvas.drawPath(rightPage, pagePaint);

    // Add a center divider shadow line for the book fold
    final foldPaint = Paint()
      ..color = AppColors.grayBorder
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx, bookTop + bookHeight * 0.5),
      Offset(center.dx, bookTop + bookHeight * 0.94),
      foldPaint,
    );

    // 5. Draw Sparkles / Light Beams
    final sparklePaint = Paint()
      ..color = AppColors.greyLight
      ..style = PaintingStyle.fill;

    // Draw a few small diamond sparkles emitting upwards
    _drawSparkle(canvas, Offset(center.dx - 25, bookTop + 5), 3, sparklePaint);
    _drawSparkle(canvas, Offset(center.dx + 30, bookTop + 12), 4, sparklePaint);
    _drawSparkle(canvas, Offset(center.dx - 5, bookTop - 12), 2.5, sparklePaint);
    _drawSparkle(canvas, Offset(center.dx + 12, bookTop - 5), 3.5, sparklePaint);
  }

  void _drawSparkle(Canvas canvas, Offset offset, double radius, Paint paint) {
    final path = Path()
      ..moveTo(offset.dx, offset.dy - radius)
      ..lineTo(offset.dx + radius * 0.5, offset.dy)
      ..lineTo(offset.dx, offset.dy + radius)
      ..lineTo(offset.dx - radius * 0.5, offset.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
