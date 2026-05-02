import 'package:flutter/material.dart';
import '../../models/hero_model.dart';
import '../../widgets/power_stat_bar.dart';

class HeroDetailScreen extends StatelessWidget {
  final HeroModel? hero;

  const HeroDetailScreen({Key? key, required this.hero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hero == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hero Details')),
        body: const Center(child: Text('No hero data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(hero?.name ?? 'Hero'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Image
            Container(
              height: 100,
              color: Colors.grey.withOpacity(0.1),
              child: Image.network(
                hero!.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Alignment
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hero?.name ?? 'Unknown',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            if (hero?.fullName != null &&
                                hero!.fullName.isNotEmpty)
                              Text(
                                hero!.fullName,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(hero!.alignment),
                        backgroundColor: _getAlignmentColor(hero!.alignment),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Power Stats
                  Text(
                    'Power Stats',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _PowerStatsDisplay(powerStats: hero!.powerStats),
                  const SizedBox(height: 24),
                  // Game Stats
                  _GameStatsDisplay(hero: hero!),
                  const SizedBox(height: 24),
                  // Biography
                  _BiographySection(hero: hero!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAlignmentColor(String alignment) {
    switch (alignment.toLowerCase()) {
      case 'good':
        return Colors.green.withOpacity(0.3);
      case 'bad':
        return Colors.red.withOpacity(0.3);
      case 'neutral':
        return Colors.grey.withOpacity(0.3);
      default:
        return Colors.blue.withOpacity(0.3);
    }
  }
}

class _PowerStatsDisplay extends StatelessWidget {
  final PowerStats powerStats;

  const _PowerStatsDisplay({required this.powerStats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PowerStatBar(
          label: 'Intelligence',
          value: powerStats.intelligence,
        ),
        PowerStatBar(
          label: 'Strength',
          value: powerStats.strength,
        ),
        PowerStatBar(
          label: 'Speed',
          value: powerStats.speed,
        ),
        PowerStatBar(
          label: 'Durability',
          value: powerStats.durability,
        ),
        PowerStatBar(
          label: 'Power',
          value: powerStats.power,
        ),
        PowerStatBar(
          label: 'Combat',
          value: powerStats.combat,
        ),
      ],
    );
  }
}

class _GameStatsDisplay extends StatelessWidget {
  final HeroModel hero;

  const _GameStatsDisplay({required this.hero});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Game Stats',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _GameStatRow('Max HP', hero.maxHp.toString()),
              _GameStatRow('Attack', hero.attack.toString()),
              _GameStatRow('Special Attack', hero.specialAttack.toString()),
              _GameStatRow('Defense', hero.defense.toString()),
              _GameStatRow('Initiative', hero.initiative.toString()),
            ],
          ),
        ),
      ],
    );
  }
}

class _GameStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _GameStatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _BiographySection extends StatelessWidget {
  final HeroModel hero;

  const _BiographySection({required this.hero});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biography',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _InfoRow('Publisher', hero.publisher),
        const SizedBox(height: 8),
        _InfoRow('Alignment', hero.alignment),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}
