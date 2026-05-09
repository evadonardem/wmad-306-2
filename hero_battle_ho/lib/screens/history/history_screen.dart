import 'package:flutter/material.dart';

import '../../models/battle_record.dart';
import '../../services/database_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Widget _buildRecordTile(BattleRecord record) {
    final resultText = record.playerWon ? 'Win' : 'Loss';
    final resultColor = record.playerWon ? Colors.green : Colors.red;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: resultColor,
          child: Text(
            resultText,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
        title: Text('${record.playerHero} vs ${record.aiHero}'),
        subtitle: Text('Rounds: ${record.roundsPlayed}\nDate: ${record.playedAt}'),
        isThreeLine: true,
      ),
    );
  }

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
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return const Center(child: Text('No battle history yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _buildRecordTile(history[index]),
          );
        },
      ),
    );
  }
}
