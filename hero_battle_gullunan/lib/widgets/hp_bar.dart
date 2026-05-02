import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  final int currentHp;
  final int maxHp;
  final String label;

  const HpBar({
    required this.currentHp,
    required this.maxHp,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = currentHp / maxHp;
    final color = percentage > 0.5
        ? Colors.green
        : percentage > 0.25
        ? Colors.orange
        : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            minHeight: 20,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text('$currentHp / $maxHp'),
      ],
    );
  }
}
