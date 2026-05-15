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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: hero.imageUrl.isEmpty
                  ? const ColoredBox(
                      color: Colors.black12,
                      child: Icon(Icons.person, size: 72),
                    )
                  : CachedNetworkImage(imageUrl: hero.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          Text(hero.fullName ?? hero.publisher ?? 'Unknown origin',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          StatRow(label: 'Intelligence', value: hero.intelligence),
          StatRow(label: 'Strength', value: hero.strength),
          StatRow(label: 'Speed', value: hero.speed),
          StatRow(label: 'Durability', value: hero.durability),
          StatRow(label: 'Power', value: hero.power),
          StatRow(label: 'Combat', value: hero.combat),
          const SizedBox(height: 20),
          Consumer<DeckProvider>(
            builder: (context, deck, _) {
              final inDeck = deck.contains(hero);
              return ElevatedButton.icon(
                icon: Icon(inDeck ? Icons.remove : Icons.add),
                label: Text(inDeck ? 'Remove from Deck' : 'Add to Deck'),
                onPressed: () {
                  if (inDeck) {
                    deck.removeHero(hero);
                  } else {
                    deck.addHero(hero);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
