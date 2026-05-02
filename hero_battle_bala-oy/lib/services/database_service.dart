import 'dart:convert';
import 'dart:io' show Platform;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

import '../models/battle_record.dart';
import '../models/hero_model.dart';

class DatabaseService {
	DatabaseService._internal();
	static final DatabaseService _instance = DatabaseService._internal();
	factory DatabaseService() => _instance;

	Database? _db;
	static bool _isInitialized = false;

	void _ensureDatabaseFactoryInitialized() {
		if (_isInitialized) {
			return;
		}

		if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
			sqflite_ffi.sqfliteFfiInit();
			databaseFactory = sqflite_ffi.databaseFactoryFfi;
		}

		_isInitialized = true;
	}

	Future<Database> get database async {
		_ensureDatabaseFactoryInitialized();
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

	// -- Deck CRUD ------------------------------------------------------------
	Future<int> saveDeck(String name, List<HeroModel> heroes) async {
		final db = await database;
		final incomingSignature = _heroIdSignatureFromHeroes(heroes);

		final existingRows = await db.query(
			'decks',
			where: 'name = ?',
			whereArgs: [name],
		);

		for (final row in existingRows) {
			final existingSignature = _heroIdSignatureFromDeckRow(row);
			if (existingSignature == incomingSignature) {
				throw StateError(
					'A deck with the same name and heroes already exists.',
				);
			}
		}

		return db.insert('decks', {
			'name': name,
			'heroes': jsonEncode(heroes.map((h) => h.toJson()).toList()),
			'created': DateTime.now().toIso8601String(),
		});
	}

	String _heroIdSignatureFromHeroes(List<HeroModel> heroes) {
		final ids = heroes.map((h) => h.id).toList()..sort();
		return ids.join('|');
	}

	String _heroIdSignatureFromDeckRow(Map<String, Object?> row) {
		final heroesJson = row['heroes'] as String?;
		if (heroesJson == null || heroesJson.isEmpty) {
			return '';
		}

		final decoded = jsonDecode(heroesJson) as List<dynamic>;
		final ids = decoded
				.map((item) => (item as Map<String, dynamic>)['id'].toString())
				.toList()
			..sort();
		return ids.join('|');
	}

	Future<List<Map<String, dynamic>>> loadDecks() async {
		final db = await database;
		return db.query('decks', orderBy: 'created DESC');
	}

	List<HeroModel> parseDeckHeroes(Map<String, dynamic> row) {
		final heroesJson = row['heroes'] as String?;
		if (heroesJson == null || heroesJson.isEmpty) {
			return <HeroModel>[];
		}

		final decoded = jsonDecode(heroesJson) as List<dynamic>;
		return decoded
				.map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
				.toList();
	}

	Future<void> deleteDeck(int id) async {
		final db = await database;
		await db.delete('decks', where: 'id = ?', whereArgs: [id]);
	}

	// -- Battle History -------------------------------------------------------
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

