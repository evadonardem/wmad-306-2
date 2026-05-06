import 'package:flutter/material.dart';

import '../../../core/models/pokemon_stat.dart';

/// Horizontal bar visualising a single base stat. Width is proportional to
/// [maxValue] (defaults to 200, the practical PokéAPI ceiling for base stats).
class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.stat,
    required this.color,
    this.maxValue = 200,
  });

  final PokemonStat stat;
  final Color color;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final fraction = (stat.baseValue / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              stat.displayLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              stat.baseValue.toString(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: fraction),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
