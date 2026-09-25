import 'package:bible_app/core/theme/app_colors.dart';
import 'package:bible_app/features/hymns/database/hymn_database.dart';
import 'package:bible_app/features/hymns/models/hymn.dart';
import 'package:bible_app/features/hymns/repositories/hymn_repository.dart';
import 'package:bible_app/features/hymns/screens/hymns_details_screen.dart';
import 'package:flutter/material.dart';

class FavoriteHymnsScreen extends StatefulWidget {
  const FavoriteHymnsScreen({
    super.key,
  });

  @override
  State<FavoriteHymnsScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteHymnsScreen> {
  late final HymnRepository _repository;

  List<Hymn> _favorites = [];

  bool _isLoading = true;

  String? _error;

  @override
  void initState() {
    super.initState();

    _repository = HymnRepository(
      databaseHelper: HymnDatabase.instance,
    );

    _loadFavorites();
  }

  // ============================================================
  // LOAD FAVORITES
  // ============================================================

  Future<void> _loadFavorites({
    bool isRefresh = false,
  }) async {
    try {
      if (!isRefresh) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final favorites = await _repository.getFavoriteHymns();

      if (!mounted) return;

      setState(() {
        _favorites = favorites;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint(
        'Favorite hymns loading error: $e',
      );

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshFavorites() async {
    await _loadFavorites(
      isRefresh: true,
    );
  }

  // ============================================================
  // OPEN DETAIL
  // ============================================================

  Future<void> _openHymn(Hymn hymn) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => HymnDetailScreen(
          hymn: hymn,
        ),
      ),
    );

    if (!mounted) return;

    // ALWAYS reload from SQLite when returning.
    await _loadFavorites(
      isRefresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SDA Hymnal',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Error: $_error',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.error,
            fontSize: 14,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refreshFavorites,
      child: _favorites.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: constraints.maxHeight,
                      child: const Center(
                        child: Text(
                          'No favorite hymns',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _favorites.length,
              padding: const EdgeInsets.only(
                bottom: 120,
              ),
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.greyLightest,
                );
              },
              itemBuilder: (context, index) {
                final hymn = _favorites[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  title: Text(
                    '${hymn.number.toString().padLeft(3, '0')} - '
                    '${hymn.title}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () {
                    _openHymn(hymn);
                  },
                );
              },
            ),
    );
  }
}
