import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/stat_row.dart';

class HeroDetailScreen extends StatefulWidget {
  final HeroModel hero;

  const HeroDetailScreen({super.key, required this.hero});

  @override
  State<HeroDetailScreen> createState() => _HeroDetailScreenState();
}

class _HeroDetailScreenState extends State<HeroDetailScreen> {
  int _imageRetryCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.hero.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.network(
                '${widget.hero.imageUrl}?t=$_imageRetryCount',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[400],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Loading hero...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[900],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Image unavailable',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.grey[400], size: 32),
                        onPressed: () {
                          setState(() {
                            _imageRetryCount++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Hero Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Name and Publisher
                  Text(
                    widget.hero.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.hero.publisher} • ${widget.hero.alignment}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  if (widget.hero.fullName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Real Name: ${widget.hero.fullName}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Stats
                  const Text(
                    'Power Stats',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  StatRow(label: 'Max HP', value: widget.hero.maxHp, maxValue: 200),
                  StatRow(label: 'Attack', value: widget.hero.attack, maxValue: 150),
                  StatRow(label: 'Special Attack', value: widget.hero.specialAttack, maxValue: 150),
                  StatRow(label: 'Defense', value: widget.hero.defense, maxValue: 50),
                  StatRow(label: 'Initiative', value: widget.hero.initiative, maxValue: 200),
                  const SizedBox(height: 24),

                  // Add to Deck Button
                  Consumer<DeckProvider>(
                    builder: (context, deck, _) {
                      final inDeck = deck.contains(widget.hero);
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            backgroundColor: inDeck ? Colors.red : const Color(0xFF7B2FBE),
                          ),
                          onPressed: inDeck
                              ? () => deck.removeHero(widget.hero)
                              : deck.isFull
                                  ? null
                                  : () => deck.addHero(widget.hero),
                          icon: Icon(inDeck ? Icons.remove : Icons.add),
                          label: Text(
                            inDeck ? 'Remove from Deck' : 'Add to Deck',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}