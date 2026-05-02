import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/stat_row.dart';

class HeroDetailScreen extends StatelessWidget {
  final HeroModel hero;

  const HeroDetailScreen({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    final Color alignmentColor = switch (hero.alignment.toLowerCase()) {
      'good' => Colors.green,
      'bad' => Colors.red,
      _ => Colors.grey,
    };

    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (hero.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: hero.imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) =>
                    _buildImagePlaceholder(),
              )
            else
              _buildImagePlaceholder(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hero.fullName.isNotEmpty &&
                      hero.fullName != hero.name)
                    Text(
                      "Real Name: ${hero.fullName}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                  Text(
                    "Alignment: ${hero.alignment.toUpperCase()}",
                    style: TextStyle(
                      color: alignmentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Divider(),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Power Stats",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),

                  for (final stat in [
                    (label: "Intelligence", value: hero.powerStats.intelligence, color: Colors.blue),
                    (label: "Strength", value: hero.powerStats.strength, color: Colors.red),
                    (label: "Speed", value: hero.powerStats.speed, color: Colors.green),
                    (label: "Durability", value: hero.powerStats.durability, color: Colors.orange),
                    (label: "Power", value: hero.powerStats.power, color: Colors.purple),
                    (label: "Combat", value: hero.powerStats.combat, color: Colors.grey),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: StatRow(
                        label: stat.label,
                        value: stat.value.toString(),
                        color: stat.color,
                      ),
                    ),

                  const SizedBox(height: 20),

                  Consumer<DeckProvider>(
                    builder: (context, deckProvider, child) {
                      final inDeck = deckProvider.contains(hero);

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                inDeck ? Colors.red : Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (inDeck) {
                              deckProvider.removeHero(hero);
                            } else {
                              if (deckProvider.isFull) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Deck is full (Max 5)!"),
                                  ),
                                );
                              } else {
                                deckProvider.addHero(hero);
                              }
                            }
                          },
                          child: Text(
                            inDeck
                                ? "REMOVE FROM DECK"
                                : "ADD TO DECK",
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

  Widget _buildImagePlaceholder() {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(
        Icons.broken_image,
        size: 100,
        color: Colors.grey,
      ),
    );
  }
}