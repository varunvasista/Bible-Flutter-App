import 'dart:async';

import 'package:bible_app/features/hymns/screens/hymns_details_screen.dart';
import 'package:bible_app/features/hymns/screens/hymns_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/service_locator.dart';
import '../../features/bible/screens/translation_selection_screen.dart';
import '../../features/bible/screens/testament_selection_screen.dart';
import '../../features/home/screens/today_screen.dart';
import '../../features/journal/screens/journal_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/home/widgets/floating_bottom_navigation.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Root shell of the app.
///
/// Hosts a [BottomNavigationBar] with five tabs:
///   0 — Home (spiritual dashboard)
///   1 — Bible reader (TranslationSelectionScreen)
///   2 — Journal (JournalScreen)
///   3 — Kyrie (PanicScreen)
///   4 — Profile (SettingsScreen)
///
/// Each tab is wrapped in its own [Navigator] so navigation within a tab
/// (e.g. Bible: translation → testament → book → chapter → verse) is
/// independent and preserved when switching tabs.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoaded = false;

  late GlobalKey<NavigatorState> _todayNavKey;
  late GlobalKey<NavigatorState> _bibleNavKey;
  late GlobalKey<NavigatorState> _journalNavKey;
  late GlobalKey<NavigatorState> _hymnsNavKey;
  late GlobalKey<NavigatorState> _profileNavKey;

  @override
  void initState() {
    super.initState();
    _initNavKeys();
    tabSwitchRequest.addListener(_onTabSwitchRequest);
    appResetNotifier.addListener(_onAppReset);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  void _initNavKeys() {
    _todayNavKey = GlobalKey<NavigatorState>();
    _bibleNavKey = GlobalKey<NavigatorState>();
    _journalNavKey = GlobalKey<NavigatorState>();
    _hymnsNavKey = GlobalKey<NavigatorState>();
    _profileNavKey = GlobalKey<NavigatorState>();
  }

  @override
  void dispose() {
    tabSwitchRequest.removeListener(_onTabSwitchRequest);
    appResetNotifier.removeListener(_onAppReset);
    super.dispose();
  }

  void _onTabSwitchRequest() {
    final tab = tabSwitchRequest.value;
    if (tab != null) {
      _selectTab(tab);
      tabSwitchRequest.value = null;
    }
  }

  void _selectTab(int index) {
    if (index == 0) {
      _todayNavKey.currentState?.popUntil((route) => route.isFirst);
    }
    setState(() => _currentIndex = index);
  }

  void _onAppReset() {
    setState(() {
      _currentIndex = 0;
      _initNavKeys();
    });
  }

  Future<void> _initializeApp() async {
    debugPrint('Starting background initialization...');
    bibleDatasetInitInProgressNotifier.value = true;

    try {
      final bibleLoadFuture = localBibleService.loadBible().then((_) {
        bibleDatasetReadyNotifier.value = localBibleService.isLoaded;
      });

      await bibleLoadFuture;
    } catch (e) {
      debugPrint('Initialization error: $e');
    } finally {
      bibleDatasetReadyNotifier.value = localBibleService.isLoaded;
      bibleDatasetInitInProgressNotifier.value = false;
    }

    aiModelInitInProgressNotifier.value = true;
    unawaited(
      gemmaModelService.initializeModel().then((_) {
        aiModelReadyNotifier.value = gemmaModelService.isReady;
      }).catchError((Object e, StackTrace _) {
        aiModelReadyNotifier.value = false;
        debugPrint('Gemma background initialization failed: $e');
      }).whenComplete(() {
        aiModelInitInProgressNotifier.value = false;
      }),
    );

    if (!mounted) return;
    setState(() {
      _isLoaded = true;
    });
  }

  // ── Android back-button handling ───────────────────────────────────────────
  Future<bool> _onWillPop() async {
    final keys = [
      _todayNavKey,
      _bibleNavKey,
      _journalNavKey,
      _hymnsNavKey,
      _profileNavKey,
    ];
    final innerNav = keys[_currentIndex].currentState;
    if (innerNav != null && innerNav.canPop()) {
      innerNav.pop();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 335,
                    height: 335,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Advent Bible',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                  height: 1.0,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: bibleDatasetInitInProgressNotifier,
      builder: (_, bibleLoading, __) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            final shouldPop = await _onWillPop();
            if (shouldPop) {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            extendBody: true,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: aiModelReadyNotifier,
                    builder: (_, ready, __) {
                      if (ready) return const SizedBox.shrink();
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        color: AppColors.black,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI initializing...',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: [
                        _TabNavigator(
                          navigatorKey: _todayNavKey,
                          builder: () => const TodayScreen(),
                        ),
                        _TabNavigator(
                          navigatorKey: _bibleNavKey,
                          builder: () {
                            if (settingsService.hasPreferredTranslation) {
                              return TestamentSelectionScreen(
                                translation:
                                    settingsService.preferredTranslation,
                              );
                            }
                            return const TranslationSelectionScreen();
                          },
                        ),
                        _TabNavigator(
                          navigatorKey: _journalNavKey,
                          builder: () => const JournalScreen(),
                        ),
                        _TabNavigator(
                          navigatorKey: _hymnsNavKey,
                          builder: () => HymnListScreen(
                            onHymnSelected: (hymn) {
                              _hymnsNavKey.currentState?.push(
                                MaterialPageRoute(
                                  builder: (_) => HymnDetailScreen(
                                    hymn: hymn,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        _TabNavigator(
                          navigatorKey: _profileNavKey,
                          builder: () => const SettingsScreen(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              color: AppColors.transparent,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FloatingBottomNavigation(
                currentIndex: _currentIndex,
                onTap: _selectTab,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Wraps a tab's root widget in its own [Navigator] so each tab maintains an
/// independent navigation stack.
class _TabNavigator extends StatelessWidget {
  const _TabNavigator({
    required this.navigatorKey,
    required this.builder,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (_) => builder(),
      ),
    );
  }
}
