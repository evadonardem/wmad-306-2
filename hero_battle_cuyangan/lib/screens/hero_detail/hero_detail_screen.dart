import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/hp_bar.dart';
import '../../widgets/stat_row.dart';

class HeroDetailScreen extends StatelessWidget {
  final HeroModel hero;

  const HeroDetailScreen({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hero.name),
        actions: [
          // GOOD: Consumer wraps only the button that needs to rebuild
          Consumer<DeckProvider>(
            builder: (context, deck, child) {
              final inDeck = deck.contains(hero);
              return IconButton(
                onPressed: inDeck
                    ? () => deck.removeHero(hero)
                    : deck.isFull
                    ? null
                    : () => deck.addHero(hero),
                icon: Icon(inDeck ? Icons.favorite : Icons.favorite_border),
                tooltip: inDeck ? 'Remove from Deck' : 'Add to Deck',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image and Basic Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Hero(
                  tag: 'hero-${hero.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: hero.displayImageUrl.isNotEmpty
                          ? hero.displayImageUrl
                          : 'https://via.placeholder.com/120x120.png?text=No+Image',
                      cacheKey: hero
                          .name, // Use hero name as cache key to prevent constant re-fetching
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      httpHeaders: {"User-Agent": "Mozilla/5.0"},
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) {
                        // Let the proxy handle the 'No Image' state via &default= parameter
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Basic Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hero.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      if (hero.fullName.isNotEmpty &&
                          hero.fullName != hero.name)
                        Text(
                          'Full Name: ${hero.fullName}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Publisher: ${hero.publisher}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Alignment: ${hero.alignment}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Battle Stats
            Text(
              'Battle Stats',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            // HP Bar
            HpBar(current: hero.maxHp, max: hero.maxHp, label: 'HP'),
            const SizedBox(height: 8),

            // Derived Stats
            StatRow(label: 'Attack', value: hero.attack),
            StatRow(label: 'Special Attack', value: hero.specialAttack),
            StatRow(label: 'Defense', value: hero.defense),
            StatRow(label: 'Initiative', value: hero.initiative),

            const SizedBox(height: 24),

            // Power Stats
            Text(
              'Power Stats',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            StatRow(label: 'Intelligence', value: hero.powerStats.intelligence),
            StatRow(label: 'Strength', value: hero.powerStats.strength),
            StatRow(label: 'Speed', value: hero.powerStats.speed),
            StatRow(label: 'Durability', value: hero.powerStats.durability),
            StatRow(label: 'Power', value: hero.powerStats.power),
            StatRow(label: 'Combat', value: hero.powerStats.combat),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Consumer<DeckProvider>(
                    builder: (context, deck, child) {
                      final inDeck = deck.contains(hero);
                      return ElevatedButton.icon(
                        onPressed: inDeck
                            ? () {
                                deck.removeHero(hero);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${hero.name} removed from deck',
                                    ),
                                  ),
                                );
                              }
                            : deck.isFull
                            ? null
                            : () {
                                deck.addHero(hero);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${hero.name} added to deck'),
                                  ),
                                );
                              },
                        icon: Icon(inDeck ? Icons.remove : Icons.add),
                        label: Text(
                          inDeck ? 'Remove from Deck' : 'Add to Deck',
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
