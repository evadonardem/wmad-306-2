import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/hp_bar.dart';

class BattleScreen extends StatefulWidget {
  final HeroModel attacker;

  const BattleScreen({super.key, required this.attacker});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  HeroModel? defender;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final heroes = context.read<HeroSearchProvider>().heroes;
      defender = _chooseDefender(heroes, widget.attacker);
      _startBattle();
    });
  }

  HeroModel _chooseDefender(List<HeroModel> heroes, HeroModel attacker) {
    final options = heroes.where((hero) => hero.id != attacker.id).toList();
    if (options.isEmpty) {
      return attacker;
    }
    return options[Random().nextInt(options.length)];
  }

  Future<void> _startBattle() async {
    if (defender == null) return;
    final battleProvider = context.read<BattleProvider>();
    final battleRecord = await battleProvider.fight(widget.attacker, defender!);
    if (!mounted) return;
    if (battleRecord.winnerName == widget.attacker.name) {
      context.read<PlayerProvider>().incrementWins();
    }
  }

  @override
  Widget build(BuildContext context) {
    final battle = context.watch<BattleProvider>();
    final record = battle.latestBattle;

    return Scaffold(
      appBar: AppBar(title: const Text('Battle Arena')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: battle.isFighting
            ? const Center(child: CircularProgressIndicator())
            : record == null
                ? const Center(child: Text('Preparing battle...'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(record.summary, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      _combatCard(widget.attacker, record.winnerName == widget.attacker.name),
                      const SizedBox(height: 12),
                      _combatCard(defender!, record.winnerName == defender!.name),
                      const SizedBox(height: 20),
                      Text('Winner: ${record.winnerName}', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Back to deck'),
                      )
                    ],
                  ),
      ),
    );
  }

  Widget _combatCard(HeroModel hero, bool winner) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hero.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(winner ? 'Victory' : 'Defeated', style: TextStyle(color: winner ? Colors.green : Colors.red)),
            const SizedBox(height: 8),
            HpBar(value: hero.totalPower, maxValue: 600),
          ],
        ),
      ),
    );
  }
}
