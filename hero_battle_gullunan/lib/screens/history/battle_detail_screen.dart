import 'package:flutter/material.dart';
import '../../models/battle_record.dart';
import '../../widgets/hero_card.dart';

class BattleDetailScreen extends StatelessWidget {
  final BattleRecord record;

  const BattleDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(record.playedAt);
    final formattedDate =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Battle Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: record.playerWon ? Colors.green.shade800 : Colors.red.shade800,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        record.playerWon ? Icons.emoji_events : Icons.shield_moon,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          record.playerWon ? 'VICTORY' : 'DEFEAT',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${record.playerHero} vs ${record.aiHero}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildBadge(context, 'Rounds ${record.roundsPlayed}'),
                      _buildBadge(context, 'Player team ${record.playerTeam.length}'),
                      _buildBadge(context, 'AI team ${record.aiTeam.length}'),
                      _buildBadge(context, formattedDate),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Player Team',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            if (record.playerTeam.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No team data available'),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: record.playerTeam.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) => HeroCard(hero: record.playerTeam[index]),
              ),
            const SizedBox(height: 24),
            Text(
              'AI Team',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            if (record.aiTeam.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No team data available'),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: record.aiTeam.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) => HeroCard(hero: record.aiTeam[index]),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}
