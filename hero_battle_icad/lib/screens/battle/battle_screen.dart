import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Battle Arena")),
      body: Consumer<BattleProvider>(
        builder: (context, battle, child) {
          if (battle.currentPlayerHero == null ||
              battle.currentAiHero == null) {
            return const Center(child: Text("No Battle Active"));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TeamPanel(
                      title: 'Player Team',
                      heroes: battle.playerHeroes,
                      activeHero: battle.currentPlayerHero!,
                      hp: battle.playerHp,
                      color: Colors.blue,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 24.0,
                      ),
                      child: Text(
                        "VS",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _TeamPanel(
                      title: 'AI Team',
                      heroes: battle.aiHeroes,
                      activeHero: battle.currentAiHero!,
                      hp: battle.aiHp,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildHeroCarousel(
                        'Player Lineup',
                        battle.playerHeroes,
                        battle.currentPlayerHero!,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildHeroCarousel(
                        'AI Lineup',
                        battle.aiHeroes,
                        battle.currentAiHero!,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: battle.battleLog.length,
                    itemBuilder: (context, index) => Text(
                      battle.battleLog[index],
                      style: TextStyle(
                        fontWeight: index == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: index == 0
                            ? Colors.blueAccent
                            : Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: battle.isBattleOver
                        ? () => Navigator.pop(context)
                        : () => battle.executeTurn(),
                    child: Text(
                      battle.isBattleOver ? "EXIT BATTLE" : "ATTACK!",
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroCarousel(
    String title,
    List<HeroModel> heroes,
    HeroModel activeHero,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: heroes.length,
            itemBuilder: (context, index) {
              final hero = heroes[index];
              final isActive = hero.id == activeHero.id;
              return Container(
                width: 90,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isActive ? Colors.amber : Colors.grey.shade400,
                    width: isActive ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: CachedNetworkImage(
                        imageUrl: hero.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error_outline),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        hero.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TeamPanel extends StatelessWidget {
  final String title;
  final List<HeroModel> heroes;
  final HeroModel activeHero;
  final int hp;
  final Color color;

  const _TeamPanel({
    required this.title,
    required this.heroes,
    required this.activeHero,
    required this.hp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          height: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: activeHero.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error_outline),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          activeHero.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        _HpBar(hp: hp, maxHp: activeHero.maxHp, color: color),
      ],
    );
  }
}

class _HpBar extends StatelessWidget {
  final int hp;
  final int maxHp;
  final Color color;

  const _HpBar({required this.hp, required this.maxHp, required this.color});

  @override
  Widget build(BuildContext context) {
    final width = maxHp > 0 ? (hp / maxHp).clamp(0.0, 1.0) * 100 : 0.0;
    return Column(
      children: [
        Stack(
          children: [
            Container(width: 100, height: 10, color: Colors.grey[300]),
            Container(width: width, height: 10, color: color),
          ],
        ),
        const SizedBox(height: 4),
        Text('$hp / $maxHp HP', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
