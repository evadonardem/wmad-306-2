import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/battle_record.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'hero_battle.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE battle_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playerHeroId TEXT,
        playerHeroName TEXT,
        opponentHeroId TEXT,
        opponentHeroName TEXT,
        winnerId TEXT,
        winnerName TEXT,
        date TEXT
      )
    ''');
  }

  Future<void> insertBattleRecord(BattleRecord record) async {
    final db = await database;
    await db.insert('battle_records', record.toMap());
  }

  Future<List<BattleRecord>> getBattleRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('battle_records');
    return List.generate(maps.length, (i) {
      return BattleRecord.fromMap(maps[i]);
    });
  }
}