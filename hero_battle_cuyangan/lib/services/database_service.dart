import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/battle_record.dart';
import '../models/hero_model.dart';
import '../models/battle_history_model.dart';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    // Ensure the battle_history_detailed table exists
    await _ensureBattleHistoryDetailedTable();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'hero_battle.db'),
      version: 3, // Increment version for migration
      onCreate: (db, version) async {
        // Wipe and Rebuild: Drop table if it exists to clear old database
        await db.execute('DROP TABLE IF EXISTS decks');
        await db.execute('DROP TABLE IF EXISTS battle_history');

        // Correct the onCreate SQL: Fix table formatting
        await db.execute(
          'CREATE TABLE decks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, heroes TEXT)',
        );
        print('Table decks created successfully with column: heroes');
        await db.execute('''
          CREATE TABLE battle_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            player_hero TEXT NOT NULL,
            ai_hero TEXT NOT NULL,
            player_won INTEGER NOT NULL, 
            rounds_played INTEGER NOT NULL,
            played_at TEXT NOT NULL
          )''');

        // Create the new battle_history_detailed table
        await db.execute('''
          CREATE TABLE battle_history_detailed (
            id TEXT PRIMARY KEY,
            playerTeamName TEXT NOT NULL,
            opponentName TEXT NOT NULL,
            finalScore TEXT NOT NULL,
            battleDate TEXT NOT NULL,
            winner TEXT NOT NULL,
            playerHeroes TEXT NOT NULL,
            opponentHeroes TEXT NOT NULL,
            battleSummary TEXT NOT NULL
          )''');
        print('Table battle_history_detailed created successfully');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle database migration for existing installations
        if (oldVersion < 3) {
          // Create the battle_history_detailed table if it doesn't exist
          await db.execute('''
            CREATE TABLE IF NOT EXISTS battle_history_detailed (
              id TEXT PRIMARY KEY,
              playerTeamName TEXT NOT NULL,
              opponentName TEXT NOT NULL,
              finalScore TEXT NOT NULL,
              battleDate TEXT NOT NULL,
              winner TEXT NOT NULL,
              playerHeroes TEXT NOT NULL,
              opponentHeroes TEXT NOT NULL,
              battleSummary TEXT NOT NULL
            )''');
          print('Table battle_history_detailed created via migration');
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
    });
  }

  Future<List<Map<String, dynamic>>> loadDecks() async {
    final db = await database;
    return db.query('decks', orderBy: 'id DESC');
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

  Future<void> saveBattleResult({
    required List<HeroModel> playerDeck,
    required List<HeroModel> aiDeck,
    required String winner,
    required int playerPower,
    required int aiPower,
  }) async {
    final db = await database;
    await db.insert('battle_history', {
      'player_hero': jsonEncode(playerDeck.map((h) => h.toJson()).toList()),
      'ai_hero': jsonEncode(aiDeck.map((h) => h.toJson()).toList()),
      'player_won': winner == 'Player' ? 1 : (winner == 'Draw' ? 0 : -1),
      'rounds_played': 1, // Simplified battle format
      'played_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<BattleRecord>> loadHistory() async {
    final db = await database;
    final rows = await db.query('battle_history', orderBy: 'played_at DESC');
    return rows.map(BattleRecord.fromMap).toList();
  }

  // Battle History Methods
  Future<void> saveBattleHistory(BattleHistoryModel battle) async {
    final db = await database;
    await db.insert('battle_history_detailed', battle.toMap());
  }

  Future<List<BattleHistoryModel>> getBattleHistory() async {
    final db = await database;
    final rows = await db.query(
      'battle_history_detailed',
      orderBy: 'battleDate DESC',
    );
    return rows.map(BattleHistoryModel.fromMap).toList();
  }

  Future<void> clearBattleHistory() async {
    final db = await database;
    await db.delete('battle_history_detailed');
  }

  // Ensure the battle_history_detailed table exists (for existing databases)
  Future<void> _ensureBattleHistoryDetailedTable() async {
    try {
      final db = _db!;
      // Check if table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='battle_history_detailed'",
      );

      if (tables.isEmpty) {
        // Table doesn't exist, create it
        await db.execute('''
          CREATE TABLE battle_history_detailed (
            id TEXT PRIMARY KEY,
            playerTeamName TEXT NOT NULL,
            opponentName TEXT NOT NULL,
            finalScore TEXT NOT NULL,
            battleDate TEXT NOT NULL,
            winner TEXT NOT NULL,
            playerHeroes TEXT NOT NULL,
            opponentHeroes TEXT NOT NULL,
            battleSummary TEXT NOT NULL
          )''');
        print(
          'battle_history_detailed table created successfully (safety check)',
        );
      }
    } catch (e) {
      print('Error ensuring battle_history_detailed table: $e');
    }
  }
}
