import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hero_model.dart';
import '../providers/deck_provider.dart';
import '../router/app_router.dart';

class HeroCard extends StatefulWidget {
  final HeroModel hero;

  const HeroCard({super.key, required this.hero});

  @override
  State<HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<HeroCard> {
  int _retryCount = 0;

  // Build a simple loading/placeholder
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, RouteNames.heroDetail, arguments: widget.hero),
              child: Container(
                color: Colors.grey[300],
                width: double.infinity,
                child: Stack(
                  children: [
                    Image.network(
                      '${widget.hero.imageUrl}?t=$_retryCount',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildPlaceholder();
                      },
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, RouteNames.heroDetail, arguments: widget.hero),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.hero.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          widget.hero.publisher,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Consumer<DeckProvider>(
                    builder: (context, deck, _) {
                      final inDeck = deck.contains(widget.hero);
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: inDeck
                              ? () => deck.removeHero(widget.hero)
                              : deck.isFull
                                  ? null
                                  : () => deck.addHero(widget.hero),
                          icon: Icon(inDeck ? Icons.remove : Icons.add, size: 16),
                          label: Text(inDeck ? 'Remove' : 'Add', style: const TextStyle(fontSize: 12)),
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
    );
  }
}
