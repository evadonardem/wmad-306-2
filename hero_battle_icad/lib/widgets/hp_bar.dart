import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  final int currentHp;
  final int maxHp;
  final String label;

  const HpBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (currentHp / maxHp).clamp(0.0, 1.0);
    final isLow = percentage <= 0.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('$currentHp / $maxHp HP', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 12,
            backgroundColor: Colors.grey.shade300,
            color: isLow ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }
}