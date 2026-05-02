import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/battle_record.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<BattleRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    // Queries the SQLite db and maps to BattleRecord objects
    _historyFuture = DatabaseService.instance.database.then((db) async {
      final maps = await db.query('battle_history', orderBy: 'id DESC');
      return maps.map((map) => BattleRecord.fromMap(map)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battle History (Exercise 2)')),
      body: FutureBuilder<List<BattleRecord>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error loading history: ${snapshot.error}'));
          }

          final records = snapshot.data ?? [];

          // Empty state handling
          if (records.isEmpty) {
            return const Center(
              child: Text(
                'No battles fought yet.\nGo to the Arena!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final won = record.playerWon;
              
              return ListTile(
                leading: Icon(won ? Icons.emoji_events : Icons.sentiment_dissatisfied, 
                              color: won ? Colors.amber : Colors.red),
                title: Text('${record.playerHero} vs ${record.aiHero}'),
                subtitle: Text('Rounds: ${record.roundsPlayed} • ${record.playedAt.split('T').first}'),
                trailing: Text(
                  won ? 'VICTORY' : 'DEFEAT',
                  style: TextStyle(fontWeight: FontWeight.bold, color: won ? Colors.green : Colors.red),
                ),
              );
            },
          );
        },
      ),
    );
  }
}