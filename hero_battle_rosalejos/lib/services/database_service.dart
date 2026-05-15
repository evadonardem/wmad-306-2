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
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE decks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            heroes TEXT NOT NULL, -- JSON array
            created TEXT NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE battle_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            player_hero TEXT NOT NULL,
            ai_hero TEXT NOT NULL,
            ai_name TEXT,
            player_won INTEGER NOT NULL, -- 1 = win, 0 = loss
            rounds_played INTEGER NOT NULL,
            played_at TEXT NOT NULL,
            player_deck_images TEXT,
            ai_deck_images TEXT,
            player_deck_json TEXT,
            ai_deck_json TEXT
          )''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE battle_history ADD COLUMN player_deck_images TEXT');
          await db.execute('ALTER TABLE battle_history ADD COLUMN ai_deck_images TEXT');
          await db.execute('ALTER TABLE battle_history ADD COLUMN ai_name TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE battle_history ADD COLUMN player_deck_json TEXT');
          await db.execute('ALTER TABLE battle_history ADD COLUMN ai_deck_json TEXT');
        }
        if (oldVersion < 4) {
          // Repair migration: Ensures all required columns exist regardless of previous upgrade path.
          final tableInfo = await db.rawQuery('PRAGMA table_info(battle_history)');
          final columns = tableInfo.map((e) => e['name'] as String).toSet();
          
          final requiredColumns = {
            'ai_name': 'TEXT',
            'player_deck_images': 'TEXT',
            'ai_deck_images': 'TEXT',
            'player_deck_json': 'TEXT',
            'ai_deck_json': 'TEXT',
          };

          for (var entry in requiredColumns.entries) {
            if (!columns.contains(entry.key)) {
              await db.execute('ALTER TABLE battle_history ADD COLUMN ${entry.key} ${entry.value}');
            }
          }
        }
      },
    );
  }

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

  Future<void> saveBattleRecord(BattleRecord record) async {
    final db = await database;
    await db.insert('battle_history', record.toMap());
  }

  Future<List<BattleRecord>> loadHistory() async {
    final db = await database;
    final rows = await db.query('battle_history', orderBy: 'played_at DESC');
    return rows.map(BattleRecord.fromMap).toList();
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('decks');
    await db.delete('battle_history');
  }
}
