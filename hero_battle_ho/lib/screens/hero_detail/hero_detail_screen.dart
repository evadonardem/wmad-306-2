import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';

class HeroDetailScreen extends StatelessWidget {
  const HeroDetailScreen({super.key, required this.hero});

  final HeroModel hero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Full Name: ${hero.fullName.isEmpty ? 'Unknown' : hero.fullName}'),
            const SizedBox(height: 8),
            Text('Publisher: ${hero.publisher.isEmpty ? 'Unknown' : hero.publisher}'),
            const SizedBox(height: 8),
            Text('Alignment: ${hero.alignment}'),
            const SizedBox(height: 16),
            Consumer<DeckProvider>(
              builder: (context, deck, child) {
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
          ],
        ),
      ),
    );
  }
}
