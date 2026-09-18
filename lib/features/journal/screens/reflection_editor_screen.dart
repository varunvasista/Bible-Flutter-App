import 'package:flutter/material.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class ReflectionEditorScreen extends StatefulWidget {
  const ReflectionEditorScreen({
    super.key,
    required this.onSave,
    this.initialTitle = '',
    this.initialContent = '',
    this.initialTags = const [],
  });

  final Future<void> Function(String title, String content, List<String> tags) onSave;
  final String initialTitle;
  final String initialContent;
  final List<String> initialTags;

  @override
  State<ReflectionEditorScreen> createState() => _ReflectionEditorScreenState();
}

class _ReflectionEditorScreenState extends State<ReflectionEditorScreen> with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isSaving = false;

  late final AnimationController _entranceController;
  late final Animation<double> _fadeInAnimation;
  late final Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    _fabScaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  String _formatDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSaving = true);
    await widget.onSave(title, content, widget.initialTags);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Top Toolbar (Close button only)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.primary, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),

              // Main Editor Section (occupies all remaining vertical space)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 3. Note Metadata
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.iosBackground,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Text(
                              'NEW REFLECTION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.iosGray,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.systemGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // 4. Title Field
                      TextField(
                        controller: _titleController,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia',
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black,
                          height: 1.25,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText: 'Title of your reflection',
                          hintStyle: TextStyle(
                            color: AppColors.sepiaBorder,
                            fontFamily: 'Georgia',
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 5. Reflection Content Editor (Expands to fill all remaining vertical space)
                      Expanded(
                        child: TextField(
                          controller: _contentController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.white.withOpacity(0.9) : AppColors.systemGrayDark,
                            height: 1.6,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Begin writing from the heart...',
                            hintStyle: TextStyle(
                              color: AppColors.iosDivider,
                              fontSize: 18,
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // 7. Floating Save Button with Scale Entrance Animation
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: _AnimatedFloatingActionButton(
          onPressed: _isSaving ? null : _handleSave,
          isSaving: _isSaving,
        ),
      ),
      floatingActionButtonLocation: _CustomFloatingActionButtonLocation(mediaQuery),
    );
  }
}

class _AnimatedFloatingActionButton extends StatefulWidget {
  const _AnimatedFloatingActionButton({
    required this.onPressed,
    required this.isSaving,
  });

  final VoidCallback? onPressed;
  final bool isSaving;

  @override
  State<_AnimatedFloatingActionButton> createState() => _AnimatedFloatingActionButtonState();
}

class _AnimatedFloatingActionButtonState extends State<_AnimatedFloatingActionButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _pressController;
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          _pressController.reverse();
        }
      },
      onTapUp: (_) {
        if (widget.onPressed != null) {
          _pressController.forward();
        }
      },
      onTapCancel: () {
        if (widget.onPressed != null) {
          _pressController.forward();
        }
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: 60,
          height: 60,
          child: Material(
            elevation: 12,
            shadowColor: AppColors.black.withOpacity(0.3),
            shape: const CircleBorder(),
            color: AppColors.primary,
            child: InkWell(
              onTap: widget.onPressed,
              customBorder: const CircleBorder(),
              splashColor: AppColors.white.withOpacity(0.15),
              highlightColor: AppColors.white.withOpacity(0.05),
              child: const Center(
                child: Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const _CustomFloatingActionButtonLocation(this.mediaQuery);

  final MediaQueryData mediaQuery;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double screenWidth = scaffoldGeometry.scaffoldSize.width;
    final double fabWidth = scaffoldGeometry.floatingActionButtonSize.width;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;

    // Center of the Profile tab icon:
    // Bottom navigation is centered in a container with 16px padding on left/right.
    // FloatingBottomNavigation has 10px horizontal padding inside.
    // There are 4 items of equal width: (screenWidth - 52.0) / 4.0
    // The center of the 4th item (Profile) from left is: 26.0 + 3.5 * itemWidth.
    final double itemWidth = (screenWidth - 52.0) / 4.0;
    final double profileCenter = 26.0 + 3.5 * itemWidth;

    // Align the FAB's center with the Profile icon's center:
    final double x = profileCenter - (fabWidth / 2.0);

    // In Flutter, mediaQuery.padding.bottom already includes the bottom navigation bar height
    // and the system safe area bottom padding when extendBody is true on the parent Scaffold.
    // Therefore, subtracting mediaQuery.padding.bottom places the FAB exactly on top of the bottom navigation bar.
    final double bottomInset = mediaQuery.padding.bottom;

    final double y = scaffoldGeometry.scaffoldSize.height -
        fabHeight -
        bottomInset;

    return Offset(x, y);
  }
}
