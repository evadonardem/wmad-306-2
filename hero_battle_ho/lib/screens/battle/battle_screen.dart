import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/hp_bar.dart';
import '../../widgets/stat_row.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  String? _playerHeroId;
  String? _aiHeroId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final deck = context.read<DeckProvider>().deck;
    if (deck.length >= 2) {
      _playerHeroId ??= deck.first.id;
      _aiHeroId ??= deck.firstWhere((h) => h.id != _playerHeroId).id;
    }
  }

  HeroModel? _findHero(List<HeroModel> heroes, String? id) {
    if (id == null) return null;
    for (final hero in heroes) {
      if (hero.id == id) return hero;
    }
    return null;
  }

  Future<void> _startBattle() async {
    final deck = context.read<DeckProvider>().deck;
    final player = _findHero(deck, _playerHeroId);
    final ai = _findHero(deck, _aiHeroId);

    if (player == null || ai == null || player.id == ai.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose two different heroes.')),
      );
      return;
    }

    context.read<BattleProvider>().startBattle(playerHero: player, aiHero: ai);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battle')),
      body: Consumer2<DeckProvider, BattleProvider>(
        builder: (context, deckProvider, battle, _) {
          final deck = deckProvider.deck;

          if (deck.length < 2) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Add at least 2 heroes to your deck before starting a battle.'),
              ),
            );
          }

          final aiChoices = deck.where((h) => h.id != _playerHeroId).toList();
          if (_aiHeroId != null && aiChoices.every((h) => h.id != _aiHeroId)) {
            _aiHeroId = aiChoices.isEmpty ? null : aiChoices.first.id;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!battle.isBattleActive && battle.playerWon == null) ...[
                  DropdownButtonFormField<String>(
                    key: ValueKey('player-$_playerHeroId'),
                    initialValue: _playerHeroId,
                    decoration: const InputDecoration(
                      labelText: 'Player Hero',
                      border: OutlineInputBorder(),
                    ),
                    items: deck
                        .map((h) => DropdownMenuItem(value: h.id, child: Text(h.name)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _playerHeroId = value;
                        if (_aiHeroId == value) {
                          _aiHeroId = deck.firstWhere((h) => h.id != value).id;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey('ai-$_aiHeroId'),
                    initialValue: _aiHeroId,
                    decoration: const InputDecoration(
                      labelText: 'AI Hero',
                      border: OutlineInputBorder(),
                    ),
                    items: aiChoices
                        .map((h) => DropdownMenuItem(value: h.id, child: Text(h.name)))
                        .toList(),
                    onChanged: (value) => setState(() => _aiHeroId = value),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _startBattle,
                    child: const Text('Start Battle'),
                  ),
                ] else ...[
                  Text('Round: ${battle.round}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(battle.playerHero?.name ?? 'Player'),
                  HpBar(
                    currentHp: battle.playerHp,
                    maxHp: battle.playerHero?.maxHp ?? 1,
                  ),
                  const SizedBox(height: 8),
                  StatRow(
                    label: 'ATK / DEF',
                    value: '${battle.playerHero?.attack ?? 0} / ${battle.playerHero?.defense ?? 0}',
                  ),
                  const SizedBox(height: 12),
                  Text(battle.aiHero?.name ?? 'AI'),
                  HpBar(
                    currentHp: battle.aiHp,
                    maxHp: battle.aiHero?.maxHp ?? 1,
                  ),
                  const SizedBox(height: 8),
                  StatRow(
                    label: 'ATK / DEF',
                    value: '${battle.aiHero?.attack ?? 0} / ${battle.aiHero?.defense ?? 0}',
                  ),
                  const SizedBox(height: 16),
                  if (battle.isBattleActive)
                    FilledButton(
                      onPressed: () => context.read<BattleProvider>().playRound(),
                      child: const Text('Play Next Round'),
                    )
                  else ...[
                    Text(
                      battle.playerWon == true ? 'You won!' : 'You lost!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.read<BattleProvider>().resetBattle(),
                      child: const Text('Reset Battle'),
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                Text('Battle Log', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: battle.battleLog.length,
                    itemBuilder: (context, index) => ListTile(
                      dense: true,
                      title: Text(battle.battleLog[index]),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
