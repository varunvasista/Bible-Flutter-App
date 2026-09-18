import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/service_locator.dart';
import '../../../data/models/bible_verse.dart';
import '../../../data/models/panic_entry.dart';
import '../services/panic_guidance_service.dart';
import '../services/text_processing_service.dart';
import '../widgets/panic_input_field.dart';
import 'kyrie_history_screen.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Main Kyrie spiritual support screen.
///
/// Step 5 upgrades over Step 2:
///   • Uses [PanicGuidanceService] end-to-end RAG pipeline.
///   • Auto-saves every session to [PanicHistoryService].
///   • "Copy response" — copies formatted guidance text to clipboard.
///   • Verse chips are tappable and open [_VerseBottomSheet].
///   • History icon in the AppBar navigates to [PanicHistoryScreen].
class PanicScreen extends StatefulWidget {
  const PanicScreen({super.key});

  @override
  State<PanicScreen> createState() => _PanicScreenState();
}

class _PanicScreenState extends State<PanicScreen> {
  final _controller = TextEditingController();
  final _scrollKey = GlobalKey();

  PanicEntry? _result;
  bool _isLoading = false;
  String? _error;
  bool _savedToHistory = false;
  String? _aiFormattedResponse;
  bool _isFormatting = false;

  // RAG pipeline result
  List<BibleVerse> _ragVerses = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final message = _controller.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe what you\'re feeling first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
      _savedToHistory = false;
      _aiFormattedResponse = null;
      _isFormatting = false;
    });

    // Yield one frame so the loading indicator renders before the scoring loop.
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    try {
      final PanicGuidanceResult result =
          await panicGuidanceService.handleUserMessage(message);

      // Auto-save session to history.
      await panicHistoryService.saveEntry(message, result.entry.id);

      setState(() {
        _result = result.entry;
        _aiFormattedResponse = result.responseText;
        _isLoading = false;
        _savedToHistory = true;
        _isFormatting = false;
        _ragVerses = result.fetchedVerses;
      });

      await Future.delayed(const Duration(milliseconds: 120));
      if (mounted && _scrollKey.currentContext != null) {
        Scrollable.ensureVisible(
          _scrollKey.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      setState(() {
        _error = msg.isEmpty ? 'Something went wrong. Please try again.' : msg;
        _isLoading = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _result = null;
      _error = null;
      _savedToHistory = false;
      _aiFormattedResponse = null;
      _isFormatting = false;
      _ragVerses = const [];
    });
    _controller.clear();
  }

  void _copyResponse() {
    final text = _aiFormattedResponse?.trim();
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Response copied to clipboard.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openVerse(String verseRef) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _VerseBottomSheet(verseRef: verseRef),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PanicHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        title: const Text(
          'Kyrie',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _openHistory,
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Kyrie history',
          ),
          if (_result != null)
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.white70, size: 18),
              label: const Text('New',
                  style: TextStyle(color: AppColors.white70, fontSize: 13)),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              const SizedBox(height: 20),
              PanicInputField(
                controller: _controller,
                onSubmit: _search,
                isLoading: _isLoading,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                _ErrorBanner(message: _error!),
              ],
              if (_result != null) ...[
                const SizedBox(height: 28),
                const _ResultDivider(),
                const SizedBox(height: 16),
                _UserMessageBubble(message: _controller.text.trim()),
                const SizedBox(height: 12),
                _AiRewriteCard(
                  text: _aiFormattedResponse,
                  isLoading: _isFormatting,
                ),
                if (_ragVerses.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ScriptureContextCard(verses: _ragVerses),
                ],
                const SizedBox(height: 10),
                SizedBox(key: _scrollKey, height: 0),
                if (_result != null)
                  _RecommendedVersesRow(
                    verses: _result!.response.recommendedVerses,
                    onVerseTap: _openVerse,
                  ),
                const SizedBox(height: 8),
                _ActionRow(
                  onCopy: _copyResponse,
                  savedToHistory: _savedToHistory,
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendedVersesRow extends StatelessWidget {
  const _RecommendedVersesRow({
    required this.verses,
    required this.onVerseTap,
  });

  final List<String> verses;
  final void Function(String verseRef) onVerseTap;

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderDark,
          width: 1,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: verses
            .map(
              (v) => ActionChip(
                onPressed: () => onVerseTap(v),
                label: Text(v),
                avatar: const Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                  color: AppColors.black,
                ),
                backgroundColor: AppColors.borderLight,
                side: const BorderSide(color: AppColors.borderDark),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.black),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.church_rounded,
            size: 42,
            color: AppColors.white,
          ),
          const SizedBox(height: 10),
          Text(
            'You are not alone.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          const Text(
            "Share what you're feeling.\nGod's Word has guidance for you.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultDivider extends StatelessWidget {
  const _ResultDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.borderDark)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Response',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.borderDark)),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.redShade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── New widgets (Step 5) ──────────────────────────────────────────────────────

/// Bubble showing the user's message above the response card.
class _UserMessageBubble extends StatelessWidget {
  const _UserMessageBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          message,
          style: const TextStyle(color: AppColors.white, fontSize: 14),
        ),
      ),
    );
  }
}

/// Row of action buttons shown below the response card.
class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.onCopy, required this.savedToHistory});

  final VoidCallback onCopy;
  final bool savedToHistory;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilledButton.tonalIcon(
          onPressed: onCopy,
          icon: const Icon(Icons.copy_rounded, size: 16),
          label: const Text('Copy'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        if (savedToHistory)
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  size: 15, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 4),
              Text(
                'Saved to history',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _AiRewriteCard extends StatelessWidget {
  const _AiRewriteCard({required this.text, required this.isLoading});

  final String? text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Pastoral Rewrite (Gemma Local)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Formatting response locally...'),
              ],
            )
          else
            Text(
              text ??
                  'Local AI formatting unavailable. Structured guidance is shown below.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.kyrieDarkGrey,
              ),
            ),
        ],
      ),
    );
  }
}

/// Bottom sheet that looks up a verse from KJV and displays it with options.
class _VerseBottomSheet extends StatefulWidget {
  const _VerseBottomSheet({required this.verseRef});

  final String verseRef;

  @override
  State<_VerseBottomSheet> createState() => _VerseBottomSheetState();
}

class _VerseBottomSheetState extends State<_VerseBottomSheet> {
  String? _verseText;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVerse();
  }

  Future<void> _loadVerse() async {
    final parsed = TextProcessingService.parseVerseRef(widget.verseRef);
    if (parsed == null) {
      setState(() {
        _error = 'Could not parse verse reference.';
        _loading = false;
      });
      return;
    }

    try {
      final verse = bibleRepo.getVerse(
        'KJV',
        parsed.book,
        parsed.chapter,
        parsed.verse,
      );
      setState(() {
        _verseText = verse?.text;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Verse not found in the local database.';
        _loading = false;
      });
    }
  }

  void _copyVerse() {
    if (_verseText == null) return;
    Clipboard.setData(
      ClipboardData(text: '${widget.verseRef}\n"$_verseText"'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verse copied to clipboard.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openInBible() {
    // Signal HomeScreen to switch to the Bible tab (index 1).
    tabSwitchRequest.value = 1;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.verseRef,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Text(_error!, style: TextStyle(color: theme.colorScheme.error))
          else
            Text(
              '"$_verseText"',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          const SizedBox(height: 20),
          if (!_loading && _error == null) ...[
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _copyVerse,
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy verse'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _openInBible,
                  icon: const Icon(Icons.menu_book_rounded, size: 16),
                  label: const Text('Open in Bible'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.black,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scripture context card – shows API-fetched verses for the detected emotion
// ---------------------------------------------------------------------------

class _ScriptureContextCard extends StatelessWidget {
  const _ScriptureContextCard({required this.verses});

  final List<BibleVerse> verses;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderDark,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_stories_rounded,
                  size: 16, color: AppColors.black),
              SizedBox(width: 6),
              Text(
                'Scripture Context',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...verses.map(
            (v) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.reference,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    v.text,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.black,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
