// Exercise 2 — Battle History from SQLite (FutureBuilder).

import 'package:flutter/material.dart';

import '../../models/battle_record.dart';
import '../../services/database_service.dart';
import '../../widgets/_neon.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final Future<List<BattleRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseService().loadHistory();
  }

  String _fmt(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battle History')),
      body: FutureBuilder<List<BattleRecord>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: kNeonCyan),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error: ${snap.error}',
                style: const TextStyle(color: kNeonMagenta),
              ),
            );
          }
          final records = snap.data ?? const [];
          if (records.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history, color: kNeonCyan, size: 64),
                    const SizedBox(height: 12),
                    Text('No battles yet',
                        style: kNeonTitle.copyWith(fontSize: 20)),
                    const SizedBox(height: 8),
                    const Text(
                      'Win a fight to see it logged here.',
                      style: TextStyle(color: kTextDim),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: records.length,
            itemBuilder: (_, i) {
              final r = records[i];
              final color = r.playerWon ? kNeonCyan : kNeonMagenta;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: neonBorder(color: color, glow: 6),
                child: ListTile(
                  leading: Icon(
                    r.playerWon ? Icons.emoji_events : Icons.close,
                    color: color,
                    size: 32,
                  ),
                  title: Text(
                    '${r.playerHero}  vs  ${r.aiHero}',
                    style: kNeonTitle.copyWith(fontSize: 14),
                  ),
                  subtitle: Text(
                    '${r.playerWon ? "WIN" : "LOSS"}  •  ${r.roundsPlayed} rounds  •  ${_fmt(r.playedAt)}',
                    style: const TextStyle(color: kTextDim, fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
