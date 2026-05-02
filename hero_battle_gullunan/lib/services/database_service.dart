import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/battle_record.dart';
import '../models/hero_model.dart';

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
        await db.execute('''
          CREATE TABLE decks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            heroes TEXT NOT NULL,
            created TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE battle_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            player_hero TEXT NOT NULL,
            ai_hero TEXT NOT NULL,
            player_team TEXT,
            ai_team TEXT,
            player_won INTEGER NOT NULL,
            rounds_played INTEGER NOT NULL,
            played_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add player_team and ai_team columns to battle_history table
          await db.execute(
            'ALTER TABLE battle_history ADD COLUMN player_team TEXT',
          );
          await db.execute(
            'ALTER TABLE battle_history ADD COLUMN ai_team TEXT',
          );
        }
      },
    );
  }

  // ── Deck CRUD ───────────────────────────────────────────────────
  Future<int> saveDeck(String name, List<HeroModel> heroes) async {
    final db = await database;
    return db.insert('decks', {
      'name': name,
      'heroes': jsonEncode(heroes.map((h) => h.toJson()).toList()),
      'created': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> loadDecks() async {
    final db = await database;
    return db.query('decks', orderBy: 'created DESC');
  }

  Future<void> deleteDeck(int id) async {
    final db = await database;
    await db.delete('decks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<HeroModel>> loadDeckHeroes(int deckId) async {
    final db = await database;
    final result = await db.query(
      'decks',
      where: 'id = ?',
      whereArgs: [deckId],
    );
    if (result.isEmpty) return [];
    final heroesJson =
        jsonDecode(result.first['heroes'] as String) as List<dynamic>;
    return heroesJson
        .map((h) => HeroModel.fromJson(h as Map<String, dynamic>))
        .toList();
  }

  // ── Battle History ──────────────────────────────────────────────
  Future<void> saveBattleRecord(BattleRecord record) async {
    final db = await database;
    await db.insert('battle_history', record.toMap());
  }

  Future<List<BattleRecord>> loadHistory() async {
    final db = await database;
    final rows = await db.query('battle_history', orderBy: 'played_at DESC');
    return rows.map(BattleRecord.fromMap).toList();
  }

  Future<void> deleteBattleRecord(int id) async {
    final db = await database;
    await db.delete('battle_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllBattleRecords() async {
    final db = await database;
    await db.delete('battle_history');
  }
}
