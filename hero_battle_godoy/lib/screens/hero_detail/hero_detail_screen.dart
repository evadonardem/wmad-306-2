import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/hero_image.dart';

class HeroDetailScreen extends StatelessWidget {
  final HeroModel hero;
  const HeroDetailScreen({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 200,
                child: HeroImage(
                  imageUrl: hero.reliableImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<DeckProvider>(
              builder: (context, deck, _) {
                final isInDeck = deck.contains(hero);
                final isFull = deck.isFull;
                return ElevatedButton(
                  onPressed: (isInDeck || isFull) ? null : () => deck.addHero(hero),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    isInDeck ? 'Already in Deck' : (isFull ? 'Deck Full' : 'Add to Deck'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Full Name: ${hero.fullName}', style: const TextStyle(fontSize: 16)),
            Text('Publisher: ${hero.publisher}', style: const TextStyle(fontSize: 16)),
            Text('Alignment: ${hero.alignment}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Power Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Intelligence: ${hero.powerStats.intelligence}'),
            Text('Strength: ${hero.powerStats.strength}'),
            Text('Speed: ${hero.powerStats.speed}'),
            Text('Durability: ${hero.powerStats.durability}'),
            Text('Power: ${hero.powerStats.power}'),
            Text('Combat: ${hero.powerStats.combat}'),
            const SizedBox(height: 16),
            const Text('Game Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Max HP: ${hero.maxHp}'),
            Text('Attack: ${hero.attack}'),
            Text('Special Attack: ${hero.specialAttack}'),
            Text('Defense: ${hero.defense}'),
            Text('Initiative: ${hero.initiative}'),
          ],
        ),
      ),
    );
  }
}
