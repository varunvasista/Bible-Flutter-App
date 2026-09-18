import 'package:flutter/material.dart';

import '../../../core/services/service_locator.dart';
import 'bible_search_screen.dart';
import 'bookmarks_screen.dart';
import 'testament_selection_screen.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Entry point for the Bible reader.
///
/// Lists all available translations. KJV is pre-loaded; others are lazy-loaded
/// when the user taps them.
class TranslationSelectionScreen extends StatefulWidget {
  const TranslationSelectionScreen({super.key, this.isChangeTranslation = false});

  final bool isChangeTranslation;

  @override
  State<TranslationSelectionScreen> createState() =>
      _TranslationSelectionScreenState();
}

class _TranslationSelectionScreenState
    extends State<TranslationSelectionScreen> {
  String? _loadingTranslation;
  late String _selectedTranslationCode;

  @override
  void initState() {
    super.initState();
    _selectedTranslationCode = settingsService.preferredTranslation;
  }

  Future<void> _onTap(String code) async {
    if (_loadingTranslation != null) return;

    if (!bibleRepo.isLoaded(code)) {
      setState(() => _loadingTranslation = code);
      try {
        await bibleRepo.ensureLoaded(code);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not load $code. Please try again.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() => _loadingTranslation = null);
        }
        return;
      }
      if (mounted) setState(() => _loadingTranslation = null);
    }

    await settingsService.savePreferredTranslation(code);
    if (!mounted) return;
    appPreferencesNotifier.value++;

    if (widget.isChangeTranslation) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => TestamentSelectionScreen(translation: code),
        ),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TestamentSelectionScreen(translation: code),
        ),
      );
    }
  }

  String _getDetailedName(String code) {
    final fullName = bibleRepo.getFullName(code);
    switch (code.toUpperCase()) {
      case 'KJV':
        return '$fullName — Public Domain';
      case 'NIV':
        return '$fullName — Biblica';
      case 'NLT':
        return '$fullName — Tyndale';
      case 'ESV':
        return 'Amplified Bible — Lockman Foundation';
      default:
        return fullName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawTranslations = bibleRepo.getTranslations();
    final desiredOrder = ['KJV', 'ESV', 'NIV', 'NLT'];
    final translations = desiredOrder.where((c) => rawTranslations.contains(c)).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Search Bible',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      BibleSearchScreen(searchService: bibleSearchService),
                ),
              );
            },
            icon: Icon(Icons.search_rounded, color: isDark ? AppColors.white : AppColors.primary, size: 22),
          ),
          IconButton(
            tooltip: 'Bookmarks',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
              );
            },
            icon: Icon(Icons.bookmark_border_rounded, color: isDark ? AppColors.white : AppColors.primary, size: 22),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Translation',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.white : AppColors.primary,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose your preferred version of the Bible.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Translation list & Continue button (grouped together)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    ...translations.map((code) {
                      final isSelected = code == _selectedTranslationCode;
                      final isLoaded = bibleRepo.isLoaded(code);
                      final isLoading = _loadingTranslation == code;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTranslationCode = code;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.darkGray : AppColors.lightMint)
                                : (isDark ? AppColors.kyrieDarkGrey : AppColors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? AppColors.white : AppColors.primary)
                                  : (isDark ? AppColors.kyrieDarkGrey : AppColors.border),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Leading mint icon container
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkGray : AppColors.borderLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  color: isDark ? AppColors.white : AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Middle text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      code == 'ESV' ? 'AMP' : code,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.white : AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getDetailedName(code),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (isLoaded) ...[
                                          Icon(
                                            Icons.check_circle_rounded,
                                            size: 13,
                                            color: isDark ? AppColors.white : AppColors.primary,
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          isLoaded ? 'Ready to read' : 'Tap to load',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isLoaded
                                                ? (isDark ? AppColors.white : AppColors.primary)
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Trailing status spinner if loading
                              if (isLoading)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isDark ? AppColors.white : AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 16),
                    
                    // Continue button (placed directly below the NLT card)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          onPressed: (_loadingTranslation != null || _selectedTranslationCode.isEmpty)
                              ? null
                              : () => _onTap(_selectedTranslationCode),
                          style: FilledButton.styleFrom(
                            backgroundColor: isDark ? AppColors.white : AppColors.primary,
                            foregroundColor: isDark ? AppColors.black : AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                          ),
                          child: _loadingTranslation != null
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Spacing to keep content clear of the floating bottom navigation bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

