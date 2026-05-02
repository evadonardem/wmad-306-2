import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';

class HeroCard extends StatelessWidget {
  final HeroModel hero;

  const HeroCard({Key? key, required this.hero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        RouteNames.heroDetail,
        arguments: hero,
      ),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Image
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.grey.withOpacity(0.1),
                child: Image.network(
                  hero.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Hero Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      hero.publisher,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    // Add to Deck Button — GOOD: only this button rebuilds
                    Consumer<DeckProvider>(
                      builder: (context, deck, _) {
                        final inDeck = deck.contains(hero);
                        return Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: inDeck
                                  ? () => deck.removeHero(hero)
                                  : deck.isFull
                                      ? null
                                      : () => deck.addHero(hero),
                              icon: Icon(
                                inDeck ? Icons.remove : Icons.add,
                                size: 16,
                              ),
                              label: Text(
                                inDeck ? 'Remove' : 'Add',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
