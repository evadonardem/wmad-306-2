import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/battle_record.dart';
import '../models/hero_model.dart';

class SavedDeck {
  final int id;
  final String name;
  final List<HeroModel> heroes;
  final String created;

  const SavedDeck({
    required this.id,
    required this.name,
    required this.heroes,
    required this.created,
  });
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'hero_battle.db'),
      version: 2,
      onCreate: (db, version) async {
        await _createDecksTable(db);
        await _createBattleHistoryTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _ensureBattleHistoryColumns(db);
        }
      },
      onOpen: (db) async {
        // Defensive migration for devices carrying older local schemas.
        await _createDecksTable(db);
        await _createBattleHistoryTable(db);
        await _ensureBattleHistoryColumns(db);
      },
    );
  }

  Future<void> _createDecksTable(Database db) {
    return db.execute('''
CREATE TABLE IF NOT EXISTS decks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  heroes TEXT NOT NULL,
  created TEXT NOT NULL
)
''');
  }

  Future<void> _createBattleHistoryTable(Database db) {
    return db.execute('''
CREATE TABLE IF NOT EXISTS battle_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  player_hero TEXT NOT NULL,
  ai_hero TEXT NOT NULL,
  player_won INTEGER NOT NULL,
  rounds_played INTEGER NOT NULL DEFAULT 1,
  played_at TEXT NOT NULL
)
''');
  }

  Future<void> _ensureBattleHistoryColumns(Database db) async {
    final columns = await db.rawQuery("PRAGMA table_info('battle_history')");
    final hasRoundsPlayed = columns.any((c) => c['name'] == 'rounds_played');
    if (!hasRoundsPlayed) {
      await db.execute(
        'ALTER TABLE battle_history ADD COLUMN rounds_played INTEGER NOT NULL DEFAULT 1',
      );
    }
  }

  Future<int> saveDeck(String name, List<HeroModel> heroes) async {
    final db = await database;
    return db.insert('decks', {
      'name': name,
      'heroes': jsonEncode(heroes.map((h) => h.toJson()).toList()),
      'created': DateTime.now().toIso8601String(),
    });
  }

  Future<List<SavedDeck>> loadDecks() async {
    final db = await database;
    final rows = await db.query('decks', orderBy: 'created DESC');
    return rows.map((row) {
      final heroJson = jsonDecode(row['heroes'] as String) as List;
      return SavedDeck(
        id: row['id'] as int,
        name: row['name'] as String,
        heroes: heroJson
            .map((e) => HeroModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        created: row['created'] as String,
      );
    }).toList();
  }

  Future<void> deleteDeck(int id) async {
    final db = await database;
    await db.delete('decks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveBattleRecord(BattleRecord record) async {
    final db = await database;
    await db.insert('battle_history', record.toMap());
  }

  Future<List<BattleRecord>> loadHistory() async {
    final db = await database;
    final rows = await db.query('battle_history', orderBy: 'played_at DESC');
    return rows.map(BattleRecord.fromMap).toList();
  }
}
