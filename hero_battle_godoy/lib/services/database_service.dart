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
            player_won INTEGER NOT NULL, -- 1 = win, 0 = loss
            rounds_played INTEGER NOT NULL,
            played_at TEXT NOT NULL
          )''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          try {
            // Recreate table with player vs AI column names
            await db.execute('DROP TABLE IF EXISTS battle_history_new');
            await db.execute('''
              CREATE TABLE battle_history_new (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                player_hero TEXT NOT NULL,
                ai_hero TEXT NOT NULL,
                player_won INTEGER NOT NULL,
                rounds_played INTEGER NOT NULL,
                played_at TEXT NOT NULL
              )
            ''');
            
            // Check which columns exist in the old table
            final tableInfo = await db.rawQuery("PRAGMA table_info(battle_history)");
            final columns = tableInfo.map((row) => row['name'] as String).toSet();
            
            // Build safe INSERT query based on available columns
            String playerColumn;
            if (columns.contains('player_hero')) {
              playerColumn = 'player_hero';
            } else if (columns.contains('player1_hero')) {
              playerColumn = 'player1_hero';
            } else {
              playerColumn = "'Unknown'";
            }
            
            String aiColumn;
            if (columns.contains('ai_hero')) {
              aiColumn = 'ai_hero';
            } else if (columns.contains('opponent_hero')) {
              aiColumn = 'opponent_hero';
            } else if (columns.contains('player2_hero')) {
              aiColumn = 'player2_hero';
            } else {
              aiColumn = "'Unknown'";
            }
            
            String wonColumn;
            if (columns.contains('player_won')) {
              wonColumn = 'player_won';
            } else if (columns.contains('player1_won')) {
              wonColumn = 'player1_won';
            } else {
              wonColumn = '0';
            }
            
            // Copy data from old table to new table
            await db.execute('''
              INSERT INTO battle_history_new (id, player_hero, ai_hero, player_won, rounds_played, played_at)
              SELECT id, 
                     $playerColumn,
                     $aiColumn,
                     $wonColumn,
                     rounds_played, 
                     played_at
              FROM battle_history
            ''');
            
            // Drop old table and rename new table
            await db.execute('DROP TABLE battle_history');
            await db.execute('ALTER TABLE battle_history_new RENAME TO battle_history');
          } catch (e) {
            // If migration fails, just drop old table and create new one
            await db.execute('DROP TABLE IF EXISTS battle_history');
            await db.execute('''
              CREATE TABLE battle_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                player_hero TEXT NOT NULL,
                ai_hero TEXT NOT NULL,
                player_won INTEGER NOT NULL,
                rounds_played INTEGER NOT NULL,
                played_at TEXT NOT NULL
              )
            ''');
          }
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

  // ── Battle History ──────────────────────────────────────────────
  Future<void> saveBattleRecord(BattleRecord record) async {
    final db = await database;
    await db.insert('battle_history', record.toMap());
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('battle_history');
  }

  Future<List<BattleRecord>> loadHistory() async {
    final db = await database;
    final rows = await db.query('battle_history', orderBy: 'played_at DESC');
    return rows.map(BattleRecord.fromMap).toList();
  }
}