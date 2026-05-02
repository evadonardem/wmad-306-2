import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/hero_portrait.dart';
import '../../widgets/stat_row.dart';

class HeroDetailScreen extends StatelessWidget {
  const HeroDetailScreen({super.key, required this.hero});

  final HeroModel hero;

  @override
  Widget build(BuildContext context) {
    final stats = hero.powerStats;

    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: ListView(
        children: [
          Stack(
            children: [
              HeroPortrait(hero: hero, height: 380, showPowerBadge: true),
              Positioned(
                left: 16,
                right: 16,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.fullName.isEmpty ? hero.name : hero.fullName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoPill(
                          icon: Icons.apartment,
                          text: hero.publisher.isEmpty
                              ? 'Unknown'
                              : hero.publisher,
                        ),
                        _InfoPill(
                          icon: Icons.flag,
                          text: hero.alignment.isEmpty
                              ? 'neutral'
                              : hero.alignment,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _BattleStat(label: 'HP', value: hero.maxHp),
                    _BattleStat(label: 'Attack', value: hero.attack),
                    _BattleStat(label: 'Special', value: hero.specialAttack),
                    _BattleStat(label: 'Defense', value: hero.defense),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Power Stats',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                StatRow(label: 'Intelligence', value: stats.intelligence),
                StatRow(label: 'Strength', value: stats.strength),
                StatRow(label: 'Speed', value: stats.speed),
                StatRow(label: 'Durability', value: stats.durability),
                StatRow(label: 'Power', value: stats.power),
                StatRow(label: 'Combat', value: stats.combat),
                const SizedBox(height: 16),
                Consumer<DeckProvider>(
                  builder: (context, deck, _) {
                    final inDeck = deck.contains(hero);
                    return FilledButton.icon(
                      onPressed: inDeck
                          ? () => deck.removeHero(hero)
                          : deck.isFull
                          ? null
                          : () => deck.addHero(hero),
                      icon: Icon(inDeck ? Icons.remove : Icons.add),
                      label: Text(inDeck ? 'Remove from Deck' : 'Add to Deck'),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BattleStat extends StatelessWidget {
  const _BattleStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
