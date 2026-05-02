import 'package:flutter/material.dart';

class HPBar extends StatelessWidget {
  final int currentHP;
  final int maxHP;
  final String label;

  const HPBar({
    super.key,
    required this.currentHP,
    required this.maxHP,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (currentHP / maxHP).clamp(0.0, 1.0).toDouble();
    final color = percentage > 0.5 ? Colors.green : percentage > 0.25 ? Colors.amber : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('$currentHP / $maxHP', style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
