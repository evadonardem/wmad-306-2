import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../services/dog_api_service.dart';

const _exploreItems = [
  {
    'title': 'Playful pups',
    'subtitle': 'High-energy companions',
    'breed': 'retriever',
    'subBreed': 'golden',
    'h': 120.0,
    'color': Colors.blue,
  },
  {
    'title': 'Nature walkers',
    'subtitle': 'Great for outdoor days',
    'breed': 'husky',
    'h': 180.0,
    'color': Colors.green,
  },
  {
    'title': 'Travel buddies',
    'subtitle': 'Compact and adaptable',
    'breed': 'pug',
    'h': 100.0,
    'color': Colors.orange,
  },
  {
    'title': 'Smart breeds',
    'subtitle': 'Quick learners and alert',
    'breed': 'poodle',
    'h': 220.0,
    'color': Colors.purple,
  },
  {
    'title': 'Family dogs',
    'subtitle': 'Warm and friendly temperaments',
    'breed': 'labrador',
    'h': 140.0,
    'color': Colors.red,
  },
  {
    'title': 'Gentle souls',
    'subtitle': 'Calm personalities',
    'breed': 'hound',
    'subBreed': 'afghan',
    'h': 160.0,
    'color': Colors.teal,
  },
  {
    'title': 'Tiny charmers',
    'subtitle': 'Small but full of character',
    'breed': 'chihuahua',
    'h': 90.0,
    'color': Colors.indigo,
  },
  {
    'title': 'Athletic picks',
    'subtitle': 'Best for active owners',
    'breed': 'malinois',
    'h': 200.0,
    'color': Colors.amber,
  },
  {
    'title': 'Rare finds',
    'subtitle': 'Interesting breeds to explore',
    'breed': 'dalmatian',
    'h': 130.0,
    'color': Colors.cyan,
  },
];

class ExploreMasonryScreen extends StatefulWidget {
  const ExploreMasonryScreen({super.key});

  @override
  State<ExploreMasonryScreen> createState() => _ExploreMasonryScreenState();
}

class _ExploreMasonryScreenState extends State<ExploreMasonryScreen> {
  final DogApiService _dogApiService = DogApiService();
  late Future<List<_ExploreCardData>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _cardsFuture = _loadCards();
  }

  Future<List<_ExploreCardData>> _loadCards() async {
    return Future.wait(
      _exploreItems.map((item) async {
        String? imageUrl;
        try {
          imageUrl = await _dogApiService.fetchRandomImage(
            breed: item['breed'] as String,
            subBreed: item['subBreed'] as String?,
          );
        } catch (_) {
          imageUrl = null;
        }

        return _ExploreCardData(
          title: item['title'] as String,
          subtitle: item['subtitle'] as String,
          height: item['h'] as double,
          color: item['color'] as Color,
          imageUrl: imageUrl,
        );
      }),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _cardsFuture = _loadCards();
    });
    await _cardsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: FutureBuilder<List<_ExploreCardData>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cards = snapshot.data ?? <_ExploreCardData>[];
          return LayoutBuilder(
            builder: (context, constraints) {
              const crossAxisCount = 2;
              const spacing = 10.0;
              final itemWidth =
                  (constraints.maxWidth - spacing * (crossAxisCount + 1)) /
                      crossAxisCount;

              return RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dog Match Ideas',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'A visual board of dog personalities and lifestyle-inspired categories, now powered by live dog images.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(crossAxisCount, (col) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: col == crossAxisCount - 1 ? 0 : spacing,
                            ),
                            child: SizedBox(
                              width: itemWidth,
                              child: Column(
                                children: [
                                  for (var i = col; i < cards.length; i += crossAxisCount)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: spacing),
                                      child: _MasonryCard(card: cards[i]),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MasonryCard extends StatelessWidget {
  final _ExploreCardData card;

  const _MasonryCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: card.height + 110,
      decoration: BoxDecoration(
        color: card.color.withValues(alpha: isDark ? 0.30 : 0.16),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: card.height,
                width: double.infinity,
                child: card.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: card.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: card.color.withValues(alpha: 0.35),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: card.color.withValues(alpha: 0.35),
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image),
                        ),
                      )
                    : Container(
                        color: card.color.withValues(alpha: 0.35),
                        alignment: Alignment.center,
                        child: const Icon(Icons.pets, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              card.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              card.subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreCardData {
  final String title;
  final String subtitle;
  final double height;
  final Color color;
  final String? imageUrl;

  const _ExploreCardData({
    required this.title,
    required this.subtitle,
    required this.height,
    required this.color,
    this.imageUrl,
  });
}
