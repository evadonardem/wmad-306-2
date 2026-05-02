import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/battle_provider.dart';
import '../../providers/player_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/hp_bar.dart';

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battle')),
      body: Consumer<BattleProvider>(
        builder: (context, battle, _) {
          final player = battle.playerHero;
          final ai = battle.aiHero;
          if (player == null || ai == null) {
            return const Center(child: Text('Start a battle from your deck.'));
          }

          if (battle.consumeWinAward()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<PlayerProvider>().incrementWins();
            });
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              HpBar(
                label: player.name,
                current: battle.playerHp,
                max: player.maxHp,
              ),
              const SizedBox(height: 16),
              HpBar(label: ai.name, current: battle.aiHp, max: ai.maxHp),
              const SizedBox(height: 24),
              Text(
                'Round ${battle.round}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: battle.isComplete || battle.isResolvingTurn
                          ? null
                          : () => battle.playerAttack(),
                      child: const Text('Attack'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: battle.isComplete || battle.isResolvingTurn
                          ? null
                          : () => battle.playerAttack(special: true),
                      child: const Text('Special'),
                    ),
                  ),
                ],
              ),
              if (battle.isResolvingTurn) ...[
                const SizedBox(height: 10),
                const LinearProgressIndicator(),
              ],
              if (battle.isComplete) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.history),
                  child: const Text('View History'),
                ),
              ],
              const SizedBox(height: 20),
              ...battle.log.map(
                (entry) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(entry),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
