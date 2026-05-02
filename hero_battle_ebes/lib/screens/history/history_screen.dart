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
    // Records are read from SQLite — not from a provider list
    _historyFuture = DatabaseService().loadHistory();
  }

  void _reload() =>
      setState(() => _historyFuture = DatabaseService().loadHistory());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battle History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<List<BattleRecord>>(
        future: _historyFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final records = snap.data!;

          // ── Empty state ──────────────────────────────────────────────
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_toggle_off,
                      size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No battle history yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  const Text(
                    'Win or lose a battle to see results here.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // ── Summary row ──────────────────────────────────────────────
          final wins = records.where((r) => r.playerWon).length;
          final losses = records.length - wins;

          return Column(
            children: [
              _SummaryBar(wins: wins, losses: losses, total: records.length),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _RecordCard(record: records[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Summary bar ───────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final int wins, losses, total;
  const _SummaryBar(
      {required this.wins, required this.losses, required this.total});

  @override
  Widget build(BuildContext context) {
    final rate = total == 0 ? 0.0 : wins / total;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(label: 'Battles', value: '$total', color: Colors.white70),
          _Stat(label: 'Wins', value: '$wins', color: Colors.greenAccent),
          _Stat(label: 'Losses', value: '$losses', color: Colors.redAccent),
          _Stat(
              label: 'Win Rate',
              value: '${(rate * 100).round()}%',
              color: Colors.amber),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
}

// ── Individual record card ────────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  final BattleRecord record;
  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.tryParse(record.playedAt);
    final dateStr = dt != null
        ? '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : record.playedAt;

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor:
              record.playerWon ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
          child: Text(record.playerWon ? '🏆' : '💀',
              style: const TextStyle(fontSize: 20)),
        ),
        title: Text.rich(
          TextSpan(children: [
            TextSpan(
              text: record.playerHero,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '  vs  ', style: TextStyle(color: Colors.grey)),
            TextSpan(
              text: record.aiHero,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ]),
        ),
        subtitle: Text(
          '${record.playerWon ? "Victory" : "Defeat"}  •  ${record.roundsPlayed} rounds  •  $dateStr',
          style: TextStyle(
            fontSize: 11,
            color: record.playerWon ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: record.playerWon
                ? Colors.green.withOpacity(0.15)
                : Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            record.playerWon ? 'WIN' : 'LOSS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: record.playerWon ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ),
      ),
    );
  }
}
