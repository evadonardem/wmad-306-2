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
    final hpPercentage = maxHp > 0 ? currentHp / maxHp : 0.0;
    final hpColor = hpPercentage > 0.5
        ? Colors.green
        : hpPercentage > 0.25
            ? Colors.orange
            : Colors.red;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('$currentHp/$maxHp', style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: hpPercentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(hpColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
