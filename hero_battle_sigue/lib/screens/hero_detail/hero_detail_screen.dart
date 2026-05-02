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
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: hero.imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const CircularProgressIndicator(),
                  errorWidget: (_, __, ___) => const Icon(Icons.person, size: 80),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(hero.name, style: Theme.of(context).textTheme.headlineMedium),
            if (hero.fullName.isNotEmpty) Text(hero.fullName),
            Text('Publisher: ${hero.publisher}'),
            Text('Alignment: ${hero.alignment}'),
            const Divider(height: 24),
            Text('Game Stats', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            StatRow(label: 'HP', value: hero.maxHp, max: 100),
            StatRow(label: 'Attack', value: hero.attack, max: 100),
            StatRow(label: 'Special', value: hero.specialAttack, max: 100),
            StatRow(label: 'Defense', value: hero.defense, max: 100),
            StatRow(label: 'Speed', value: hero.initiative, max: 100),
            const Divider(height: 24),
            Text('Power Stats', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            StatRow(label: 'Intelligence', value: hero.powerStats.intelligence, max: 100),
            StatRow(label: 'Strength', value: hero.powerStats.strength, max: 100),
            StatRow(label: 'Speed', value: hero.powerStats.speed, max: 100),
            StatRow(label: 'Durability', value: hero.powerStats.durability, max: 100),
            StatRow(label: 'Power', value: hero.powerStats.power, max: 100),
            StatRow(label: 'Combat', value: hero.powerStats.combat, max: 100),
            const SizedBox(height: 24),
            // Add to Deck button - Consumer wraps only this button
            Consumer<DeckProvider>(
              builder: (context, deck, _) {
                final inDeck = deck.contains(hero);
                return ElevatedButton.icon(
                  onPressed: inDeck
                      ? () => deck.removeHero(hero)
                      : deck.isFull
                          ? null
                          : () => deck.addHero(hero),
                  icon: Icon(inDeck ? Icons.remove : Icons.add),
                  label: Text(inDeck
                      ? 'Remove from Deck'
                      : deck.isFull
                          ? 'Deck Full (5/5)'
                          : 'Add to Deck'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
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