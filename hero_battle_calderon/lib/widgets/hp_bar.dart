import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  final int currentHp;
  final int maxHp;
  final String label;

  const HpBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
    this.label = 'HP',
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (currentHp / maxHp).clamp(0.0, 1.0);
    final Color color = percentage > 0.5 ? Colors.green : (percentage > 0.2 ? Colors.orange : Colors.red);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (label.isNotEmpty)
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text('$currentHp / $maxHp', style: const TextStyle(fontSize: 11)),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.1),
            color: color,
          ),
        ),
      ],
    );
  }
}
