import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/hero_model.dart';

class HeroCard extends StatelessWidget {
  final HeroModel hero;
  final bool selected;
  final VoidCallback? onTap;

  const HeroCard({super.key, required this.hero, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      elevation: selected ? 6 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _HeroImage(hero: hero),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hero.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ability: ${hero.ability}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _statLabel('HP', hero.maxHp.toString()),
                      _statLabel('ATK', hero.attack.toString()),
                      _statLabel('DEF', hero.defense.toString()),
                      _statLabel('SPD', hero.speed.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statLabel(String title, String value) {
    return Chip(
      label: Text('$title: $value'),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.hero});

  final HeroModel hero;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surfaceContainerHighest,
            Theme.of(context).colorScheme.surfaceContainer,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Text(
          hero.name.isNotEmpty ? hero.name[0].toUpperCase() : '?',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );

    if (hero.imageUrl.isEmpty) {
      return placeholder;
    }

    return CachedNetworkImage(
      imageUrl: hero.imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => placeholder,
      errorWidget: (context, url, error) => placeholder,
    );
  }
}
