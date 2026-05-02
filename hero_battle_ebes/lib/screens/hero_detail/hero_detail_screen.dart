import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/stat_row.dart';

class HeroDetailScreen extends StatelessWidget {
  final HeroModel hero;
  const HeroDetailScreen({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ps = hero.powerStats;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero header ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                hero.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 6)]),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: hero.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: cs.surface),
                    errorWidget: (_, __, ___) => Container(
                      color: cs.surface,
                      child: const Icon(Icons.person, size: 80),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Biography pills
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (hero.publisher.isNotEmpty)
                        _InfoChip(label: hero.publisher, icon: Icons.business),
                      if (hero.fullName.isNotEmpty)
                        _InfoChip(label: hero.fullName, icon: Icons.badge),
                      _AlignmentChip(alignment: hero.alignment),
                    ],
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // Game stats summary
                  Text('Battle Stats',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _BattleStatsRow(hero: hero)
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideX(begin: -0.1, end: 0, delay: 100.ms),

                  const SizedBox(height: 24),

                  // Power stats bars
                  Text('Power Stats',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  StatRow(label: 'Intelligence', value: ps.intelligence)
                      .animate()
                      .fadeIn(delay: 50.ms),
                  StatRow(label: 'Strength', value: ps.strength)
                      .animate()
                      .fadeIn(delay: 100.ms),
                  StatRow(label: 'Speed', value: ps.speed)
                      .animate()
                      .fadeIn(delay: 150.ms),
                  StatRow(label: 'Durability', value: ps.durability)
                      .animate()
                      .fadeIn(delay: 200.ms),
                  StatRow(label: 'Power', value: ps.power)
                      .animate()
                      .fadeIn(delay: 250.ms),
                  StatRow(label: 'Combat', value: ps.combat)
                      .animate()
                      .fadeIn(delay: 300.ms),

                  const SizedBox(height: 32),

                  // Add / Remove deck button
                  Consumer<DeckProvider>(
                    builder: (_, deck, __) {
                      final inDeck = deck.contains(hero);
                      final full = deck.isFull && !inDeck;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: inDeck
                                ? cs.error
                                : full
                                    ? cs.surfaceVariant
                                    : cs.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(inDeck
                              ? Icons.remove_circle_outline
                              : Icons.add_circle_outline),
                          label: Text(inDeck
                              ? 'Remove from Deck'
                              : full
                                  ? 'Deck Full (${DeckProvider.maxDeckSize}/${DeckProvider.maxDeckSize})'
                                  : 'Add to Deck  (${deck.deckSize}/${DeckProvider.maxDeckSize})'),
                          onPressed: full
                              ? null
                              : () {
                                  if (inDeck) {
                                    deck.removeHero(hero);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              '${hero.name} removed from deck')),
                                    );
                                  } else {
                                    deck.addHero(hero);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              '${hero.name} added to deck!')),
                                    );
                                  }
                                },
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _BattleStatsRow extends StatelessWidget {
  final HeroModel hero;
  const _BattleStatsRow({required this.hero});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(label: 'HP', value: '${hero.maxHp}', icon: '❤️'),
        _Stat(label: 'ATK', value: '${hero.attack}', icon: '⚔️'),
        _Stat(label: 'SP.ATK', value: '${hero.specialAttack}', icon: '✨'),
        _Stat(label: 'DEF', value: '${hero.defense}', icon: '🛡️'),
        _Stat(label: 'SPD', value: '${hero.initiative}', icon: '💨'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value, icon;
  const _Stat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 3),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            Text(label,
                style: const TextStyle(fontSize: 9, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Chip(
        avatar: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        padding: EdgeInsets.zero,
      );
}

class _AlignmentChip extends StatelessWidget {
  final String alignment;
  const _AlignmentChip({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (alignment) {
      'good' => (Colors.blue, 'Hero', Icons.star),
      'bad' => (Colors.red, 'Villain', Icons.bolt),
      _ => (Colors.grey, 'Neutral', Icons.remove),
    };
    return Chip(
      avatar: Icon(icon, size: 14, color: Colors.white),
      label:
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      backgroundColor: color.withOpacity(0.8),
      padding: EdgeInsets.zero,
    );
  }
}
