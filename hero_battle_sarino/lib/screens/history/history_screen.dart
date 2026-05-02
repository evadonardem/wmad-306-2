import 'package:flutter/material.dart';
import '../../models/battle_record.dart';
import '../../services/database_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battle History')),
      body: FutureBuilder<List<BattleRecord>>(
        future: DatabaseService().loadHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('No battle history yet'));
          }
          final records = snapshot.data!;
          if (records.isEmpty) {
            return const Center(child: Text('No battle history yet'));
          }
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, i) {
              final record = records[i];
              return ListTile(
                leading: Icon(
                  record.playerWon ? Icons.check_circle : Icons.cancel,
                  color: record.playerWon ? Colors.green : Colors.red,
                ),
                title: Text('${record.playerHero} vs ${record.aiHero}'),
                subtitle: Text(
                  'Rounds: ${record.roundsPlayed} - ${record.playedAt}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
