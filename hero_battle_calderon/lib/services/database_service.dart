import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/battle_record.dart';
import '../models/hero_model.dart';
import 'dart:convert';

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
      version: 3,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS battle_history');
          await db.execute('''
            CREATE TABLE battle_history (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              ai_name TEXT NOT NULL DEFAULT 'Enemy AI',
              player_team TEXT NOT NULL, -- JSON array of names
              ai_team TEXT NOT NULL, -- JSON array of names
              player_won INTEGER NOT NULL, -- 1 = win, 0 = loss
              rounds_played INTEGER NOT NULL,
              played_at TEXT NOT NULL
            )'''
          );
        } else if (oldVersion < 3) {
           await db.execute("ALTER TABLE battle_history ADD COLUMN ai_name TEXT NOT NULL DEFAULT 'Enemy AI'");
        }
      },
      onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE decks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          heroes TEXT NOT NULL, -- JSON array
          created TEXT NOT NULL
          )'''
      );
      await db.execute('''
        CREATE TABLE battle_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          ai_name TEXT NOT NULL,
          player_team TEXT NOT NULL, -- JSON array of names
          ai_team TEXT NOT NULL, -- JSON array of names
          player_won INTEGER NOT NULL, -- 1 = win, 0 = loss
          rounds_played INTEGER NOT NULL,
          played_at TEXT NOT NULL
        )'''
      );
      },
    );
  }
  //Deck CRUD 
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

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hero_battle.db');
    await deleteDatabase(path);
    _db = null;
  }

  Future<void> updateDeckName(int id, String newName) async {
    final db = await database;
    await db.update(
      'decks',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
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
}