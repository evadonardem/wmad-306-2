import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/hero_model.dart';
import '../providers/deck_provider.dart';
import '../router/app_router.dart';

class HeroCard extends StatelessWidget {
  final HeroModel hero;
  final bool showAddToDeck;

  const HeroCard({super.key, required this.hero, this.showAddToDeck = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, RouteNames.heroDetail, arguments: hero);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Image
            Expanded(flex: 3, child: _HeroImage(hero: hero)),
            // Hero Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hero.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hero.publisher,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showAddToDeck) ...[
                      const SizedBox(height: 4),
                      // GOOD: Consumer wraps only the button that needs to rebuild
                      Consumer<DeckProvider>(
                        builder: (context, deck, child) {
                          final inDeck = deck.contains(hero);
                          return ElevatedButton.icon(
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
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              minimumSize: const Size(0, 28),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          );
                        },
                      ),
                    ],
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

class _HeroImage extends StatefulWidget {
  final HeroModel hero;

  const _HeroImage({required this.hero});

  @override
  State<_HeroImage> createState() => _HeroImageState();
}

class _HeroImageState extends State<_HeroImage> {
  @override
  Widget build(BuildContext context) {
    final hero = widget.hero;
    final imageUrl = hero.displayImageUrl;

    // Debug: Remove print statements for production code

    // Implement direct image loading with standard CachedNetworkImage
    return CachedNetworkImage(
      imageUrl: imageUrl.isNotEmpty
          ? imageUrl
          : 'https://via.placeholder.com/150x200.png?text=No+Image',
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) {
        // Simple error handling: hero silhouette icon as fallback
        return Container(
          color: Colors.grey[300],
          child: Icon(Icons.person, color: Colors.grey[600]),
        );
      },
    );
  }
}
