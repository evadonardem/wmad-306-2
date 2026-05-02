import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../widgets/hp_bar.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final ScrollController _logScrollController = ScrollController();

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battle')),
      body: Container(
        color: Colors.black45,
        child: Consumer<BattleProvider>(
          builder: (context, battle, _) {
            // Auto-scroll to bottom when logs update
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_logScrollController.hasClients) {
                _logScrollController.animateTo(
                  _logScrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });

            if (battle.playerHero == null) {
              return const Center(child: Text('No battle in progress. Start one from your deck!'));
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: battle.playerHero!.reliableImageUrl,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.person,
                                  size: 80,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(duration: 300.ms),
                          const SizedBox(height: 8),
                          Text(battle.playerHero!.name, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          HpBar(
                            currentHp: battle.playerHp,
                            maxHp: battle.playerHero!.maxHp,
                            label: 'HP',
                          ),
                          const SizedBox(height: 8),
                          _buildStatRow('ATK', battle.playerHero!.attack),
                          _buildStatRow('DEF', battle.playerHero!.defense),
                          _buildStatRow('SPD', battle.playerHero!.initiative),
                          const SizedBox(height: 8),
                          if (battle.benchHeroes.isNotEmpty)
                            _buildBenchHeroes(context, battle),
                        ]),
                      ),
                      const Text('VS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Column(children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: battle.aiHero!.reliableImageUrl,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.person,
                                  size: 80,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(battle.aiHero!.name, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          HpBar(
                            currentHp: battle.aiHp,
                            maxHp: battle.aiHero!.maxHp,
                            label: 'HP',
                          ),
                          const SizedBox(height: 8),
                          _buildStatRow('ATK', battle.aiHero!.attack),
                          _buildStatRow('DEF', battle.aiHero!.defense),
                          _buildStatRow('SPD', battle.aiHero!.initiative),
                        ]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Round: ${battle.round}', 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      controller: _logScrollController,
                      itemCount: battle.battleLogs.length,
                      itemBuilder: (context, index) {
                        final log = battle.battleLogs[index];
                        Color logColor = Colors.white;
                        FontWeight fontWeight = FontWeight.normal;
                        
                        if (log.contains('Player HP')) {
                          logColor = Colors.greenAccent;
                        } else if (log.contains('AI HP')) {
                          logColor = Colors.redAccent;
                        } else if (log.startsWith('R')) {
                          fontWeight = FontWeight.bold;
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                              color: logColor,
                              fontSize: 14,
                              fontWeight: fontWeight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (!battle.battleOver)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () => battle.playRound(),
                      child: const Text('Fight Round'),
                    ),
                  ),
                if (battle.battleOver)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          battle.winnerText.isEmpty 
                              ? (battle.playerWon ? 'You Win!' : '${battle.aiHero?.name ?? 'AI'} Wins!')
                              : '${battle.winnerText}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => battle.restartBattle(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('Restart Battle'),
                            ),
                            ElevatedButton(
                              onPressed: () => battle.resetBattle(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                              child: const Text('Back to Deck'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text('$value', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBenchHeroes(BuildContext context, BattleProvider battle) {
    return Column(
      children: [
        const Text('Bench', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: battle.benchHeroes.length,
            itemBuilder: (context, index) {
              final hero = battle.benchHeroes[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _showSwapDialog(context, battle, hero),
                  child: ClipOval(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CachedNetworkImage(
                        imageUrl: hero.reliableImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSwapDialog(BuildContext context, BattleProvider battle, HeroModel benchHero) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Swap Hero'),
        content: Text('Swap ${battle.playerHero?.name} for ${benchHero.name}? This will use your turn.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              battle.swapActiveHero(benchHero);
            },
            child: const Text('Swap'),
          ),
        ],
      ),
    );
  }
}
