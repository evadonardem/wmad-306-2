import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/hero_model.dart';
import '../providers/deck_provider.dart';
import '../router/app_router.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.hero});

  final HeroModel hero;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          RouteNames.heroDetail,
          arguments: hero,
        ),
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: hero.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                hero.name,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
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