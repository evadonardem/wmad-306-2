import 'package:flutter/material.dart';

import '../../models/battle_record.dart';
import '../../services/database_service.dart';

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
    _historyFuture = DatabaseService().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battle History')),
      body: FutureBuilder<List<BattleRecord>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No battle history yet.\nFight some battles first!',
                      textAlign: TextAlign.center),
                ],
              ),
            );
          final records = snapshot.data!;
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, i) {
              final r = records[i];
              return ListTile(
                leading: Icon(
                  r.playerWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  color: r.playerWon ? Colors.amber : Colors.grey,
                ),
                title: Text('${r.playerHero} vs ${r.aiHero}'),
                subtitle: Text('${r.roundsPlayed} rounds · ${r.playedAt.substring(0, 10)}'),
                trailing: Chip(
                  label: Text(r.playerWon ? 'WIN' : 'LOSS'),
                  backgroundColor: r.playerWon ? Colors.green.shade800 : Colors.red.shade800,
                ),
              );
            },
          );
        },
      ),
    );
  }
}