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
        future: DatabaseService.instance.getBattleRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data ?? const [];
          if (records.isEmpty) {
            return const Center(child: Text('No battles recorded yet.'));
          }
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                leading: Icon(record.didWin ? Icons.emoji_events : Icons.close),
                title: Text(record.didWin ? 'Victory' : 'Defeat'),
                subtitle: Text(
                  '${record.playerScore} - ${record.opponentScore} against ${record.opponentName}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${record.createdAt.month}/${record.createdAt.day}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
