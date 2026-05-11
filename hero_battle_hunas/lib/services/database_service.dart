import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/battle_record.dart';
import '../models/hero_model.dart';

class SavedDeck {
  const SavedDeck({
    required this.id,
    required this.name,
    required this.heroes,
    required this.createdAt,
  });

  final int id;
  final String name;
  final List<HeroModel> heroes;
  final DateTime createdAt;
}

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async => _database ??= await _open();

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'hero_battle.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE battle_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            player_deck_name TEXT NOT NULL,
            opponent_name TEXT NOT NULL,
            did_win INTEGER NOT NULL,
            player_score INTEGER NOT NULL,
            opponent_score INTEGER NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE saved_decks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            heroes_json TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertBattleRecord(BattleRecord record) async {
    final db = await database;
    final map = record.toMap()..remove('id');
    return db.insert('battle_records', map);
  }

  Future<List<BattleRecord>> getBattleRecords() async {
    final db = await database;
    final rows = await db.query('battle_records', orderBy: 'created_at DESC');
    return rows.map(BattleRecord.fromMap).toList();
  }

  Future<int> saveDeck(String name, List<HeroModel> heroes) async {
    final db = await database;
    return db.insert('saved_decks', {
      'name': name,
      'heroes_json': HeroModel.encodeList(heroes),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<SavedDeck>> getSavedDecks() async {
    final db = await database;
    final rows = await db.query('saved_decks', orderBy: 'created_at DESC');
    return rows.map((row) {
      return SavedDeck(
        id: _parseInt(row['id']),
        name: row['name']?.toString() ?? 'Saved Deck',
        heroes: HeroModel.decodeList(row['heroes_json']?.toString() ?? '[]'),
        createdAt:
            DateTime.tryParse(row['created_at']?.toString() ?? '') ??
                DateTime.now(),
      );
    }).toList();
  }

  Future<void> deleteSavedDeck(int id) async {
    final db = await database;
    await db.delete('saved_decks', where: 'id = ?', whereArgs: [id]);
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
