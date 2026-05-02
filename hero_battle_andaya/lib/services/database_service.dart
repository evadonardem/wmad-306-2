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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE decks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            heroes TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE battle_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            player_hero TEXT NOT NULL,
            ai_hero TEXT NOT NULL,
            player_won INTEGER NOT NULL,
            rounds_played INTEGER NOT NULL,
            played_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveDeck(String name, List<HeroModel> heroes) async {
    final db = await database;
    final heroesJson = jsonEncode(heroes.map((h) => h.toJson()).toList());
    await db.insert(
      'decks',
      {
        'name': name,
        'heroes': heroesJson,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HeroModel>> loadDeck(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'decks',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isEmpty) return [];
    final heroesJson = maps.first['heroes'] as String;
    final List<dynamic> heroesList = jsonDecode(heroesJson);
    return heroesList.map((json) => HeroModel.fromJson(json)).toList();
  }

  Future<void> deleteDeck(int id) async {
    final db = await database;
    await db.delete(
      'decks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllDecks() async {
    final db = await database;
    return await db.query('decks', orderBy: 'created_at DESC');
  }

  Future<void> saveBattleRecord(BattleRecord record) async {
    final db = await database;
    await db.insert(
      'battle_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BattleRecord>> getAllBattleRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'battle_records',
      orderBy: 'played_at DESC',
    );
    return maps.map((map) => BattleRecord.fromMap(map)).toList();
  }
}