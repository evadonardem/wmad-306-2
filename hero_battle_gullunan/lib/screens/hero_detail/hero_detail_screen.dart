import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/stat_row.dart';

class HeroDetailScreen extends StatelessWidget {
  final HeroModel hero;

  const HeroDetailScreen({required this.hero, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hero.imageUrl.isNotEmpty)
              Center(
                child: CachedNetworkImage(
                  imageUrl: hero.imageUrl,
                  height: 300,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image),
                ),
              )
            else
              const SizedBox(height: 300),
            const SizedBox(height: 16),
            Text(hero.fullName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '${hero.publisher} • ${hero.alignment}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text('Power Stats', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            StatRow(label: 'Intelligence', value: hero.powerStats.intelligence),
            StatRow(label: 'Strength', value: hero.powerStats.strength),
            StatRow(label: 'Speed', value: hero.powerStats.speed),
            StatRow(label: 'Durability', value: hero.powerStats.durability),
            StatRow(label: 'Power', value: hero.powerStats.power),
            StatRow(label: 'Combat', value: hero.powerStats.combat),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text('Game Stats', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            StatRow(label: 'Max HP', value: hero.maxHp),
            StatRow(label: 'Attack', value: hero.attack),
            StatRow(label: 'Special Attack', value: hero.specialAttack),
            StatRow(label: 'Defense', value: hero.defense),
            StatRow(label: 'Initiative', value: hero.initiative),
            const SizedBox(height: 24),
            Consumer<DeckProvider>(
              builder: (context, deck, _) {
                final inDeck = deck.contains(hero);
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: inDeck
                        ? () {
                            deck.removeHero(hero);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${hero.name} removed')),
                            );
                          }
                        : deck.isFull
                        ? null
                        : () {
                            deck.addHero(hero);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${hero.name} added')),
                            );
                          },
                    icon: Icon(inDeck ? Icons.remove : Icons.add),
                    label: Text(inDeck ? 'Remove from Deck' : 'Add to Deck'),
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
