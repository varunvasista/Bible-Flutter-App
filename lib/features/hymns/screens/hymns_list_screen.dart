import 'package:bible_app/features/hymns/database/hymn_database.dart';
import 'package:bible_app/features/hymns/models/hymn.dart';
import 'package:bible_app/features/hymns/repositories/hymn_repository.dart';
import 'package:bible_app/features/hymns/screens/favourite_hymns_screen.dart';
import 'package:flutter/material.dart';

class HymnListScreen extends StatefulWidget {
  final ValueChanged<Hymn> onHymnSelected;

  const HymnListScreen({
    super.key,
    required this.onHymnSelected,
  });

  @override
  State<HymnListScreen> createState() => _HymnListScreenState();
}

class _HymnListScreenState extends State<HymnListScreen> {
  final TextEditingController _searchController = TextEditingController();

  late final HymnRepository _repository;

  List<Hymn> _hymns = [];
  String _searchText = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _repository = HymnRepository(
      databaseHelper: HymnDatabase.instance,
    );

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });

    _loadHymns();
  }

  Future<void> _loadHymns() async {
    try {
      // First import JSON data into SQLite.
      await _repository.importHymnsFromJson();

      // Then read hymns from SQLite.
      final hymns = await _repository.getAllHymns();

      if (!mounted) return;

      setState(() {
        _hymns = hymns;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Hymn loading error: $e');

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Hymn> _filterHymns() {
    if (_searchText.trim().isEmpty) {
      return _hymns;
    }

    final search = _searchText.toLowerCase().trim();

    return _hymns.where((hymn) {
      return hymn.number.toString().contains(search) ||
          hymn.title.toLowerCase().contains(search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredHymns = _filterHymns();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SDA Hymnal',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.star_border,
              color: Colors.black,
              size: 27,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoriteHymnsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
    body: SafeArea(
        bottom: true,
        child: _buildBody(filteredHymns),
      ),
    );
  }

  Widget _buildBody(List<Hymn> filteredHymns) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Error: $_error',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        // SEARCH
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Hymn',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade500,
              ),
              filled: true,
              fillColor: const Color(0xffeeeeee),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // LIST
        Expanded(
          child: filteredHymns.isEmpty
              ? const Center(
                  child: Text(
                    'No hymns found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: filteredHymns.length,
                  padding: const EdgeInsets.only(bottom: 120),
                  separatorBuilder: (context, index) {
                    return const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Color(0xffeeeeee),
                    );
                  },
                  itemBuilder: (context, index) {
                    final hymn = filteredHymns[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      title: Text(
                        '${hymn.number.toString().padLeft(3, '0')} - ${hymn.title}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        widget.onHymnSelected(hymn);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
