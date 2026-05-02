import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/stat_row.dart';

class HeroDetailScreen extends StatelessWidget {
  const HeroDetailScreen({super.key, required this.hero});

  final HeroModel hero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: hero.imageUrl,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            const SizedBox(height: 16),
            Text(
              hero.fullName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text('${hero.publisher} - ${hero.alignment}'),
            const SizedBox(height: 16),
            const Text('Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            StatRow(label: 'Intelligence', value: hero.powerStats.intelligence),
            StatRow(label: 'Strength', value: hero.powerStats.strength),
            StatRow(label: 'Speed', value: hero.powerStats.speed),
            StatRow(label: 'Durability', value: hero.powerStats.durability),
            StatRow(label: 'Power', value: hero.powerStats.power),
            StatRow(label: 'Combat', value: hero.powerStats.combat),
            const SizedBox(height: 16),
            const Text('Derived Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            StatRow(label: 'Max HP', value: hero.maxHp),
            StatRow(label: 'Attack', value: hero.attack),
            StatRow(label: 'Special Attack', value: hero.specialAttack),
            StatRow(label: 'Defense', value: hero.defense),
            StatRow(label: 'Initiative', value: hero.initiative),
            const SizedBox(height: 16),
            Consumer<DeckProvider>(
              builder: (context, deck, child) {
                final inDeck = deck.contains(hero);
                return ElevatedButton.icon(
                  onPressed: inDeck
                      ? () => deck.removeHero(hero)
                      : deck.isFull
                          ? null
                          : () => deck.addHero(hero),
                  icon: Icon(inDeck ? Icons.remove : Icons.add),
                  label: Text(inDeck ? 'Remove from Deck' : 'Add to Deck'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}