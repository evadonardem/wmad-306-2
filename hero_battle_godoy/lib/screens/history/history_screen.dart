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
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _historyFuture = DatabaseService().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battle History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<BattleRecord>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadHistory,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(child: Text('No battles yet. Go fight!'));
          }
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, i) {
              final record = records[i];
              return ListTile(
                leading: Icon(
                  record.playerWon ? Icons.emoji_events : Icons.close,
                  color: record.playerWon ? Colors.amber : Colors.red,
                  size: 32,
                ),
                title: Text(
                  '${record.playerHero} vs ${record.aiHero}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Rounds: ${record.roundsPlayed} • ${_formatDate(record.playedAt)}'),
                trailing: Text(
                  record.playerWon ? 'WIN' : 'LOSS',
                  style: TextStyle(
                    color: record.playerWon ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }
}
