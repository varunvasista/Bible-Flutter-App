import 'dart:convert';

import 'package:bible_app/features/hymns/database/hymn_database.dart';
import 'package:bible_app/features/hymns/models/hymn.dart';
import 'package:bible_app/features/hymns/models/hymn_section.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class HymnRepository {
  final HymnDatabase databaseHelper;

  HymnRepository({required this.databaseHelper});

  Future<void> importHymnsFromJson() async {
    final database = await databaseHelper.database;

    // Check whether hymns are already imported.
    final countResult = await database.rawQuery(
      'SELECT COUNT(*) as count FROM hymns',
    );

    final count = countResult.first['count'] as int;

    if (count > 0) {
      return;
    }

    // Read JSON file from assets.
    final jsonString = await rootBundle.loadString(
      'assets/data/hymns.json',
    );

    final List<dynamic> jsonData = jsonDecode(jsonString);

    // Insert all hymns and sections in one transaction.
    await database.transaction((transaction) async {
      for (final item in jsonData) {
        final hymn = Hymn.fromJson(item);

        await transaction.insert(
            'hymns',
            {
              'id': hymn.id,
              'number': hymn.number,
              'title': hymn.title,
            },
            conflictAlgorithm: ConflictAlgorithm.replace);

        for (final section in hymn.sections) {
          await transaction.insert(
              'hymn_sections',
              {
                'id': section.id,
                'hymn_id': hymn.id,
                'type': section.type,
                'verse_number': section.verseNumber,
                'lyrics': section.lyrics,
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }

  Future<List<Hymn>> getAllHymns() async {
    final database = await databaseHelper.database;

    final hymnRows = await database.query('hymns', orderBy: 'number ASC');

    final List<Hymn> hymns = [];

    for (final hymnRow in hymnRows) {
      final sectionRows = await database.query(
        'hymn_sections',
        where: 'hymn_id = ?',
        whereArgs: [hymnRow['id']],
        orderBy: 'rowid ASC',
      );

      final sections = sectionRows.map((section) {
        return HymnSection(
          id: section['id'] as String,
          type: section['type'] as String,
          verseNumber: section['verse_number'] as int?,
          lyrics: section['lyrics'] as String,
        );
      }).toList();

      hymns.add(
        Hymn(
          id: hymnRow['id'] as String,
          number: hymnRow['number'] as int,
          title: hymnRow['title'] as String,
          sections: sections,
        ),
      );
    }

    return hymns;
  }

  Future<void> addFavorite(String hymnId) async {
    final database = await databaseHelper.database;

    await database.insert(
        'favorites',
        {
          'hymn_id': hymnId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeFavorite(String hymnId) async {
    final database = await databaseHelper.database;

    await database.delete(
      'favorites',
      where: 'hymn_id = ?',
      whereArgs: [hymnId],
    );
  }

  Future<bool> isFavorite(String hymnId) async {
    final database = await databaseHelper.database;

    final result = await database.query(
      'favorites',
      where: 'hymn_id = ?',
      whereArgs: [hymnId],
    );

    return result.isNotEmpty;
  }

  Future<List<String>> getFavoriteIds() async {
    final database = await databaseHelper.database;

    final result = await database.query('favorites');

    return result.map((row) => row['hymn_id'] as String).toList();
  }

  Future<List<Hymn>> getFavoriteHymns() async {
    final favoriteIds = await getFavoriteIds();

    final allHymns = await getAllHymns();

    return allHymns.where((hymn) => favoriteIds.contains(hymn.id)).toList();
  }
}
