// Single power-stat row used on the Hero Detail screen.
// Custom: pulses with a neon glow when the stat is exactly 100 (rare).

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '_neon.dart';

class StatRow extends StatelessWidget {
  final String label;
  final int value;
  final int max;

  const StatRow({
    super.key,
    required this.label,
    required this.value,
    this.max = 100,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / max).clamp(0.0, 1.0);
    final isMax = value >= 100;
    final barColor = isMax ? kNeonMagenta : kNeonCyan;

    Widget bar = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Container(height: 10, color: kSurfaceHi),
          FractionallySizedBox(
            widthFactor: pct,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [barColor, barColor.withValues(alpha: 0.6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: barColor.withValues(alpha: 0.7),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Custom: rare-stat (== 100) pulse using flutter_animate.
    if (isMax) {
      bar = bar
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1500.ms, color: kNeonCyan)
          .scaleXY(end: 1.02, duration: 1500.ms);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                color: kTextDim,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: bar),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isMax ? kNeonCyan : kTextPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
