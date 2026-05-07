// Hero Detail — large neon portrait, biography, derived game stats,
// 6× StatRow (rare-stat pulse), narrow Consumer for the deck button.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/_neon.dart';
import '../../widgets/stat_row.dart';

class HeroDetailScreen extends StatelessWidget {
  final HeroModel hero;
  const HeroDetailScreen({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    final ps = hero.powerStats;
    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: neonBorder(radius: 18, glow: 18),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: hero.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const Center(
                    child: CircularProgressIndicator(color: kNeonCyan),
                  ),
                  errorWidget: (_, _, _) => const Icon(
                    Icons.broken_image,
                    color: kNeonMagenta,
                    size: 64,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hero.name,
              style: kNeonTitle.copyWith(fontSize: 28, color: kNeonCyan),
            ),
            if (hero.fullName.isNotEmpty)
              Text(
                hero.fullName,
                style: const TextStyle(color: kTextDim, fontSize: 14),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(label: hero.publisher, color: kNeonMagenta),
                _Chip(label: hero.alignment, color: kNeonCyan),
              ],
            ),
            const SizedBox(height: 20),
            _SectionTitle('Power Stats'),
            StatRow(label: 'Intelligence', value: ps.intelligence),
            StatRow(label: 'Strength', value: ps.strength),
            StatRow(label: 'Speed', value: ps.speed),
            StatRow(label: 'Durability', value: ps.durability),
            StatRow(label: 'Power', value: ps.power),
            StatRow(label: 'Combat', value: ps.combat),
            const SizedBox(height: 20),
            _SectionTitle('Battle Stats'),
            _StatTile(label: 'HP', value: hero.maxHp),
            _StatTile(label: 'Attack', value: hero.attack),
            _StatTile(label: 'Defense', value: hero.defense),
            _StatTile(label: 'Initiative', value: hero.initiative),
            const SizedBox(height: 24),
            // Narrow Consumer — only the button rebuilds.
            Consumer<DeckProvider>(
              builder: (context, deck, _) {
                final inDeck = deck.contains(hero);
                final disabled = !inDeck && deck.isFull;
                return ElevatedButton.icon(
                  onPressed: disabled
                      ? null
                      : () => inDeck
                          ? deck.removeHero(hero)
                          : deck.addHero(hero),
                  icon: Icon(inDeck ? Icons.remove : Icons.add),
                  label: Text(
                    inDeck
                        ? 'Remove from Deck'
                        : deck.isFull
                            ? 'Deck full (${DeckProvider.maxDeckSize})'
                            : 'Add to Deck (${deck.deckSize}/${DeckProvider.maxDeckSize})',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: inDeck ? kNeonMagenta : kNeonCyan,
                    foregroundColor: kBgDeep,
                    minimumSize: const Size.fromHeight(48),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: kNeonTitle.copyWith(fontSize: 18, color: kNeonMagenta),
        ),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      );
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  const _StatTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: kTextDim, fontSize: 14),
            ),
            Text(
              '$value',
              style: const TextStyle(
                color: kNeonCyan,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
}
