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
    final percentage = (currentHp / maxHp).clamp(0.0, 1.0);
    final color = percentage > 0.5
        ? Colors.green
        : percentage > 0.2
            ? Colors.orange
            : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('$currentHp / $maxHp'),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[800],
            color: color,
            minHeight: 12,
          ),
        ),
      ],
    );
  }
}
