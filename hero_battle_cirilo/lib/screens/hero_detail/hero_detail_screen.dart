import 'package:flutter/material.dart';
import '../../models/hero_model.dart';
import '../../widgets/hp_bar.dart';
import '../../widgets/stat_row.dart';

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(hero.imageUrl, fit: BoxFit.cover, height: 260),
            ),
            const SizedBox(height: 16),
            Text(hero.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            const Text('Hero Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StatRow(label: 'Intelligence', value: hero.intelligence),
            StatRow(label: 'Strength', value: hero.strength),
            StatRow(label: 'Speed', value: hero.speed),
            StatRow(label: 'Durability', value: hero.durability),
            StatRow(label: 'Power', value: hero.power),
            StatRow(label: 'Combat', value: hero.combat),
            const SizedBox(height: 24),
            const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Gender: ${hero.appearance.gender}'),
            Text('Race: ${hero.appearance.race}'),
            Text('Height: ${hero.appearance.height.join(', ')}'),
            Text('Weight: ${hero.appearance.weight.join(', ')}'),
            Text('Eyes: ${hero.appearance.eyeColor}'),
            Text('Hair: ${hero.appearance.hairColor}'),
            const SizedBox(height: 24),
            const Text('Work', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Occupation: ${hero.work.occupation}'),
            Text('Base: ${hero.work.base}'),
            const SizedBox(height: 24),
            const Text('Connections', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Group: ${hero.connections.groupAffiliation}'),
            Text('Relatives: ${hero.connections.relatives}'),
            const SizedBox(height: 24),
            HpBar(value: hero.totalPower, maxValue: 600),
          ],
        ),
      ),
    );
  }
}
