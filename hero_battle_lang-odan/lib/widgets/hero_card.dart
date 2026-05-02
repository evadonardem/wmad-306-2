import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
      clipBehavior: Clip.antiAlias,
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
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image_outlined),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    hero.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Lv. ${hero.level}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: hero.role.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: hero.role.color, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(hero.role.icon, size: 14, color: hero.role.color),
                        const SizedBox(width: 4),
                        Text(
                          hero.role.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: hero.role.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
          ],
        ),
      ),
    );
  }
}
