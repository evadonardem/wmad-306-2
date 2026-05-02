import 'package:flutter/material.dart';

import '../../models/battle_record.dart';
import '../../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final Future<List<BattleRecord>> _historyFuture;

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
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(child: Text('No battles recorded yet.'));
          }
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, i) {
              final record = records[i];
              return ListTile(
                leading: Icon(
                  record.playerWon ? Icons.emoji_events : Icons.close,
                  color: record.playerWon ? Colors.amber : Colors.redAccent,
                ),
                title: Text('${record.playerHero} vs ${record.aiHero}'),
                subtitle: Text(
                  '${record.playerWon ? 'Win' : 'Loss'} - ${record.roundsPlayed} rounds - ${record.playedAt}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
