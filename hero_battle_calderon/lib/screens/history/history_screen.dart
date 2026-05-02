import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/battle_history_provider.dart';
import '../../providers/player_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BattleHistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.history_rounded),
            SizedBox(width: 8),
            Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Consumer<BattleHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error.isNotEmpty) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          final history = provider.history;
          if (history.isEmpty) {
            return const Center(child: Text('No battle history found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: history.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final record = history[index];
              final date = DateTime.parse(record.playedAt);
              final formattedDate = DateFormat('MMM d, yyyy · HH:mm').format(date);
              
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: record.playerWon ? Colors.green.withAlpha(50) : Colors.red.withAlpha(50),
                    child: Icon(
                      record.playerWon ? Icons.emoji_events : Icons.close,
                      color: record.playerWon ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    record.playerWon ? 'VICTORY' : 'DEFEAT',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: record.playerWon ? Colors.green : Colors.red,
                      letterSpacing: 1.2,
                    ),
                  ),
                  subtitle: Text(formattedDate, style: const TextStyle(fontSize: 12)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildTeamSection(
                            Provider.of<PlayerProvider>(context, listen: false).playerName,
                            record.playerTeam,
                            Colors.blue,
                          ),
                          const Divider(height: 32),
                          _buildTeamSection(record.aiName, record.aiTeam, Colors.red),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTeamSection(String title, List<String> heroes, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 16, color: color),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: heroes.map((name) => Chip(
            label: Text(name, style: const TextStyle(fontSize: 12)),
            backgroundColor: color.withAlpha(20),
            side: BorderSide(color: color.withAlpha(50)),
            visualDensity: VisualDensity.compact,
          )).toList(),
        ),
      ],
    );
  }
}
