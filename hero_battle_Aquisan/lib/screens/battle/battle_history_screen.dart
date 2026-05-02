import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/battle_record.dart';
import '../../providers/player_provider.dart';
import '../../services/database_service.dart';

class BattleHistoryScreen extends StatefulWidget {
  const BattleHistoryScreen({super.key});

  @override
  State<BattleHistoryScreen> createState() => _BattleHistoryScreenState();
}

class _BattleHistoryScreenState extends State<BattleHistoryScreen> {
  List<BattleRecord> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final db = DatabaseService();
    final history = await db.loadHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battle History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Player: ${player.playerName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Total Battles: ${player.totalBattles}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _history.isEmpty
                      ? const Center(child: Text('No battle history yet.'))
                      : ListView.builder(
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final record = _history[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${record.playerHero} vs ${record.aiHero}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      record.playerWon ? 'Winner: ${record.playerHero}' : 'Winner: ${record.aiHero}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      'Result: ${record.playerWon ? 'Victory' : 'Defeat'}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      'Rounds: ${record.roundsPlayed}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      'Played: ${record.formattedDate}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}