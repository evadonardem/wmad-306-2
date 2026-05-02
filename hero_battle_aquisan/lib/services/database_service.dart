import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    String dbPath;
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      dbPath = await databaseFactory.getDatabasesPath();
    } else {
      dbPath = await getDatabasesPath();
    }

    return openDatabase(
      join(dbPath, 'hero_battle.db'),
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS decks (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, heroes TEXT NOT NULL, created TEXT NOT NULL)
          ''');
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE decks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            heroes TEXT NOT NULL, -- JSON array
            created TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE battle_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            player_hero TEXT NOT NULL,
            ai_hero TEXT NOT NULL,
            player_won INTEGER NOT NULL, -- 1 = win, 0 = loss
            rounds_played INTEGER NOT NULL,
            played_at TEXT NOT NULL
          )
        ''');
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

  Future<List<HeroModel>?> loadDeck(String name) async {
    final db = await database;
    final rows = await db.query(
      'decks',
      where: 'name = ?',
      whereArgs: [name],
      orderBy: 'created DESC',
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    try {
      final heroesJson = rows.first['heroes'] as String;
      final List<dynamic> decoded = jsonDecode(heroesJson);
      return decoded.map((item) {
        if (item is Map<String, dynamic>) {
          return HeroModel.fromJson(item);
        }
        throw Exception('Invalid hero data format');
      }).toList();
    } catch (e) {
      debugPrint('Error decoding deck heroes: $e');
      return null;
    }
  }

  Future<List<String>> getAllDeckNames() async {
    final db = await database;
    final rows = await db.query(
      'decks',
      columns: ['name'],
      orderBy: 'created DESC',
    );
    return rows.map((row) => row['name'] as String).toSet().toList();
  }

  Future<void> deleteDeck(String name) async {
    final db = await database;
    await db.delete('decks', where: 'name = ?', whereArgs: [name]);
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