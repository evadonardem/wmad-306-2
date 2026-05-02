import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  const HpBar({super.key, required this.current, required this.max, required this.label});
  final int current;
  final int max;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ratio = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final color = ratio > 0.5 ? Colors.green : ratio > 0.25 ? Colors.orange : Colors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $current / $max'),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: ratio,
          color: color,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
}