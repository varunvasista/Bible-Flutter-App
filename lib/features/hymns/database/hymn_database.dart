import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HymnDatabase {
  static final HymnDatabase instance = HymnDatabase._internal();

  static Database? _database;

  HymnDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'hymns.db');

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hymns (
        id TEXT PRIMARY KEY,
        number INTEGER NOT NULL,
        title TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE hymn_sections (
        id TEXT PRIMARY KEY,
        hymn_id TEXT NOT NULL,
        type TEXT NOT NULL,
        verse_number INTEGER,
        lyrics TEXT NOT NULL,
        FOREIGN KEY (hymn_id) REFERENCES hymns (id)
      )
    ''');
    await db.execute('''
  CREATE TABLE favorites (
    hymn_id TEXT PRIMARY KEY,
    FOREIGN KEY (hymn_id) REFERENCES hymns (id)
  )
''');
  }
}
