import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/battle_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final battleProvider = context.watch<BattleProvider>();
    final history = battleProvider.history;

    return Scaffold(
      appBar: AppBar(title: const Text('Battle History')),
      body: history.isEmpty
          ? const Center(child: Text('No battles recorded yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = history[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${record.attackerName} vs ${record.defenderName}', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Winner: ${record.winnerName}'),
                        const SizedBox(height: 6),
                        Text(record.summary),
                        const SizedBox(height: 6),
                        Text('Time: ${record.timestamp.toLocal()}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
