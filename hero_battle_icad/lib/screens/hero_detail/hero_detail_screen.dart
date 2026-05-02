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

    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              hero.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Real Name: ${hero.fullName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Alignment: ${hero.alignment.toUpperCase()}", style: TextStyle(color: hero.alignment == 'good' ? Colors.green : Colors.red)),
                  const Divider(),
                  const Text("Power Stats", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  StatRow(label: "Intelligence", value: hero.powerStats.intelligence, color: Colors.blue),
                  StatRow(label: "Strength", value: hero.powerStats.strength, color: Colors.red),
                  StatRow(label: "Speed", value: hero.powerStats.speed, color: Colors.green),
                  StatRow(label: "Durability", value: hero.powerStats.durability, color: Colors.orange),
                  StatRow(label: "Power", value: hero.powerStats.power, color: Colors.purple),
                  StatRow(label: "Combat", value: hero.powerStats.combat, color: Colors.grey),
                  const SizedBox(height: 20),
                  
                  // Deck Management Logic
                  Consumer<DeckProvider>(
                    builder: (context, deckProvider, child) {
                      final inDeck = deckProvider.contains(hero);
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: inDeck ? Colors.red : Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (inDeck) {
                              deckProvider.removeHero(hero);
                            } else {
                              if (deckProvider.isFull) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Deck is full (Max 5)!")),
                                );
                              } else {
                                deckProvider.addHero(hero);
                              }
                            }
                          },
                          child: Text(inDeck ? "REMOVE FROM DECK" : "ADD TO DECK"),
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