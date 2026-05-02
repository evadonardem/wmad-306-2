import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/stat_row.dart';

class HeroDetailScreen extends StatelessWidget {
  final HeroModel hero;

  const HeroDetailScreen({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 300,
            color: Colors.grey[900],
            child: Image.network(
              hero.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          hero.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hero.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text('${hero.fullName} • ${hero.publisher}',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text('Power Stats',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          StatRow(
              label: 'Intelligence',
              value: hero.powerStats.intelligence),
          StatRow(label: 'Strength', value: hero.powerStats.strength),
          StatRow(label: 'Speed', value: hero.powerStats.speed),
          StatRow(label: 'Durability', value: hero.powerStats.durability),
          StatRow(label: 'Power', value: hero.powerStats.power),
          StatRow(label: 'Combat', value: hero.powerStats.combat),
          const SizedBox(height: 24),
          Text('Game Stats',
              style: Theme.of(context).textTheme.titleLarge),
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
              final isFull = deck.isFull && !inDeck;
              
              return Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: isFull
                        ? null
                        : () {
                            if (inDeck) {
                              deck.removeHero(hero);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${hero.name} removed from deck'),
                                  duration: const Duration(milliseconds: 800),
                                ),
                              );
                            } else {
                              deck.addHero(hero);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${hero.name} added to deck'),
                                  duration: const Duration(milliseconds: 800),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: inDeck ? Colors.orange : Colors.blue,
                    ),
                    icon: Icon(inDeck ? Icons.remove : Icons.add),
                    label: Text(inDeck ? 'Remove from Deck' : 'Add to Deck'),
                  ),
                  if (isFull)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Deck is full (5/5)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Deck: ${deck.deckSize}/5',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
