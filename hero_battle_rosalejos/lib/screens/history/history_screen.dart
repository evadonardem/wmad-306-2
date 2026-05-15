import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/battle_record.dart';
import '../../services/database_service.dart';
import '../../widgets/stat_row.dart';
import '../../providers/player_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerName = context.read<PlayerProvider>().playerName;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('BATTLE HISTORY'),
        ),
        body: FutureBuilder<List<BattleRecord>>(
          future: DatabaseService().loadHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return const Center(child: Text('No battle history found.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, i) {
                final record = history[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              record.playedAt.split('T')[0],
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              record.playerWon ? 'VICTORY' : 'DEFEAT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: record.playerWon
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        // Names Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(playerName.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                            Text(record.aiName?.toUpperCase() ?? record.aiHero.toUpperCase(), 
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Decks Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSimpleCardRow(record.playerDeckImages, isPlayer: true),
                            const Text('VS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white10)),
                            _buildSimpleCardRow(record.aiDeckImages, isPlayer: false),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Rounds: ${record.roundsPlayed}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Outcome: ${record.playerWon ? "WIN" : "LOSS"}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSimpleCardRow(String deckJson, {required bool isPlayer}) {
    List<String> imageUrls = [];
    try {
      imageUrls = List<String>.from(jsonDecode(deckJson));
    } catch (_) {}

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: imageUrls.map((url) => Container(
        margin: EdgeInsets.only(
          right: isPlayer ? 2 : 0,
          left: isPlayer ? 0 : 2,
        ),
        width: 25,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white10, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.white10),
            errorWidget: (context, url, error) => const Icon(Icons.error, size: 8),
          ),
        ),
      )).toList(),
    );
  }
}