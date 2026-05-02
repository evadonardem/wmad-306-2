import 'package:flutter/material.dart';
import '../../models/hero_model.dart';
import '../../widgets/stat_row.dart';

class HeroDetailsModal extends StatelessWidget {
  final HeroModel hero;

  const HeroDetailsModal({required this.hero, super.key});

  Color _getRarityColor(HeroRarity rarity) {
    switch (rarity) {
      case HeroRarity.legendary:
        return const Color(0xFFFFD700);
      case HeroRarity.epic:
        return const Color(0xFF7B2FBE);
      case HeroRarity.rare:
        return const Color(0xFF3A8FFF);
      case HeroRarity.common:
        return const Color(0xFF8E8E8E);
    }
  }

  String _rarityToString(HeroRarity rarity) {
    switch (rarity) {
      case HeroRarity.common:
        return 'Common';
      case HeroRarity.rare:
        return 'Rare';
      case HeroRarity.epic:
        return 'Epic';
      case HeroRarity.legendary:
        return 'Legendary';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      initialChildSize: 0.75,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Hero Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 250,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: hero.imageUrl.isNotEmpty
                      ? Image.network(
                          hero.imageUrl,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.image,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Hero Name and Rarity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hero.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (hero.fullName.isNotEmpty)
                          Text(
                            hero.fullName,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Rarity Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getRarityColor(hero.rarity).withAlpha(220),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getRarityColor(hero.rarity),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _rarityToString(hero.rarity),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Divider
              Divider(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              // Stats Section
              Text(
                'Game Stats',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              StatRow(
                label: 'Max HP',
                value: hero.maxHp,
              ),
              const SizedBox(height: 12),
              StatRow(
                label: 'Attack',
                value: hero.attack,
              ),
              const SizedBox(height: 12),
              StatRow(
                label: 'Special Attack',
                value: hero.specialAttack,
              ),
              const SizedBox(height: 12),
              StatRow(
                label: 'Defense',
                value: hero.defense,
              ),
              const SizedBox(height: 12),
              StatRow(
                label: 'Initiative',
                value: hero.initiative,
              ),
              const SizedBox(height: 24),
              // Power Stats Section
              Text(
                'Power Stats',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              StatRow(
                label: 'Intelligence',
                value: hero.powerStats.intelligence,
              ),
              const SizedBox(height: 12),
              StatRow(
                label: 'Strength',
                value: hero.powerStats.strength,
              ),
              const SizedBox(height: 12),
              StatRow(
                label: 'Speed',
                value: hero.powerStats.speed,
              ),
              const SizedBox(height: 12),
              StatRow(
                label: 'Durability',
                value: hero.powerStats.durability,
              ),
              const SizedBox(height: 12),
              StatRow(
                label: 'Power',
                value: hero.powerStats.power,
              ),
              const SizedBox(height: 12),
              StatRow(
                label: 'Combat',
                value: hero.powerStats.combat,
              ),
              const SizedBox(height: 24),
              // Additional Info
              if (hero.publisher.isNotEmpty || hero.alignment.isNotEmpty)
                Column(
                  children: [
                    Divider(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    if (hero.publisher.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Publisher',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              hero.publisher,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    if (hero.alignment.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Alignment',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            hero.alignment,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                  ],
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
