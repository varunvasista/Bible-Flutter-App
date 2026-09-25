import 'package:bible_app/features/hymns/database/hymn_database.dart';
import 'package:bible_app/features/hymns/models/hymn.dart';
import 'package:bible_app/features/hymns/repositories/hymn_repository.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class HymnDetailScreen extends StatefulWidget {
  final Hymn hymn;

  const HymnDetailScreen({
    super.key,
    required this.hymn,
  });

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  late final HymnRepository _repository;

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    _repository = HymnRepository(
      databaseHelper: HymnDatabase.instance,
    );

    _checkFavorite();
  }

  // ============================================================
  // CHECK FAVORITE
  // ============================================================

  Future<void> _checkFavorite() async {
    try {
      final result = await _repository.isFavorite(widget.hymn.id);

      if (!mounted) return;

      setState(() {
        isFavorite = result;
      });
    } catch (e) {
      debugPrint('Error checking favorite: $e');
    }
  }

  // for share the hymns
Future<void> _shareHymn() async {
    final buffer = StringBuffer();

    buffer.writeln(
      '${widget.hymn.number.toString().padLeft(3, '0')} - ${widget.hymn.title}',
    );

    buffer.writeln();

    for (final section in widget.hymn.sections) {
      if (section.type == 'chorus') {
        buffer.writeln('CHORUS:');
        buffer.writeln(section.lyrics);
      } else {
        buffer.writeln('${section.verseNumber}');
        buffer.writeln(section.lyrics);
      }

      buffer.writeln();
    }

    await Share.share(
      buffer.toString(),
      subject: widget.hymn.title,
    );
  }
  // ============================================================
  // TOGGLE FAVORITE
  // ============================================================

  Future<void> _toggleFavorite() async {
    try {
      if (isFavorite) {
        await _repository.removeFavorite(widget.hymn.id);
      } else {
        await _repository.addFavorite(widget.hymn.id);
      }

      if (!mounted) return;

      setState(() {
        isFavorite = !isFavorite;
      });
    } catch (e) {
      debugPrint('Error updating favorite: $e');
    }
  }

  // ============================================================
  // BACK
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      // We handle Android/device back ourselves.
      canPop: false,

      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        // This handles Android device back button
        // and Android back gesture.
        Navigator.of(context).pop(isFavorite);
      },

      child: Scaffold(
        backgroundColor: Colors.white,

        // ========================================================
        // APP BAR
        // ========================================================

        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () {
              Navigator.of(context).pop(isFavorite);
            },
          ),
          title: const Text(
            'SDA Hymnal',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: false,
        ),

        // ========================================================
        // BODY
        // ========================================================

        body: SafeArea(
          bottom: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              28,
              8,
              30,
              100,
            ),
            children: [
              // ======================================================
              // TITLE + ACTIONS
              // ======================================================
          
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '${widget.hymn.number.toString().padLeft(3, '0')} - '
                      '${widget.hymn.title}',
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
          
                  // FAVORITE
                  IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
          
                  // SHARE
                  IconButton(
                    onPressed: _shareHymn,
                    icon: const Icon(
                      Icons.share,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                ],
              ),
          
              const SizedBox(height: 20),
          
              // ======================================================
              // LARGE TITLE
              // ======================================================
          
              Text(
                '${widget.hymn.number.toString().padLeft(3, '0')} - '
                '${widget.hymn.title}',
                textAlign: TextAlign.start,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
          
              const SizedBox(height: 20),
          
              // ======================================================
              // SECTIONS
              // ======================================================
          
              ...widget.hymn.sections.map((section) {
                // CHORUS
                if (section.type == 'chorus') {
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CHORUS:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          section.lyrics,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }
          
                // VERSE
                return Padding(
                  padding: const EdgeInsets.only(
                    top: 2,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${section.verseNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        section.lyrics,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
