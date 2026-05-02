import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/stat_row.dart';

class HeroDetailScreen extends StatelessWidget {
  const HeroDetailScreen({super.key, required this.hero});

  final HeroModel hero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: hero.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image_outlined, size: 48),
              ),
            ),
            const SizedBox(height: 16),
            Text(hero.fullName.isEmpty ? hero.name : hero.fullName),
            const SizedBox(height: 8),
            Text('Publisher: ${hero.publisher}'),
            Text('Alignment: ${hero.alignment}'),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    StatRow(label: 'Intelligence', value: hero.powerStats.intelligence),
                    StatRow(label: 'Strength', value: hero.powerStats.strength),
                    StatRow(label: 'Speed', value: hero.powerStats.speed),
                    StatRow(label: 'Durability', value: hero.powerStats.durability),
                    StatRow(label: 'Power', value: hero.powerStats.power),
                    StatRow(label: 'Combat', value: hero.powerStats.combat),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<DeckProvider>(
          builder: (context, deck, _) {
            final inDeck = deck.contains(hero);
            return ElevatedButton.icon(
              onPressed: inDeck
                  ? () => deck.removeHero(hero)
                  : deck.isFull
                      ? null
                      : () => deck.addHero(hero),
              icon: Icon(inDeck ? Icons.remove : Icons.add),
              label: Text(inDeck ? 'Remove' : 'Add to Deck'),
            );
          },
        ),
      ),
    );
  }
}
