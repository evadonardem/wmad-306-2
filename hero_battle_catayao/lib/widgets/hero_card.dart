import 'package:flutter/material.dart';

import '../models/hero_model.dart';
import '../router/app_router.dart';
import 'hero_portrait.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.hero});

  final HeroModel hero;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.28),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          RouteNames.heroDetail,
          arguments: hero,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            HeroPortrait(hero: hero, showPowerBadge: true),
            Positioned(
              left: 10,
              top: 10,
              child: _AlignmentChip(alignment: hero.alignment),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hero.publisher.isEmpty ? hero.alignment : hero.publisher,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MiniStat(label: 'ATK', value: hero.attack),
                        const SizedBox(width: 6),
                        _MiniStat(label: 'HP', value: hero.maxHp),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlignmentChip extends StatelessWidget {
  const _AlignmentChip({required this.alignment});

  final String alignment;

  @override
  Widget build(BuildContext context) {
    final normalized = alignment.toLowerCase();
    final color = normalized == 'good'
        ? const Color(0xFF22C55E)
        : normalized == 'bad'
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        alignment.isEmpty ? 'neutral' : alignment,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        alignment: Alignment.center,
        child: Text(
          '$label $value',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
