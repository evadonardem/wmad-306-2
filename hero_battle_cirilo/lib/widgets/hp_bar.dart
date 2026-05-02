import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  final int value;
  final int maxValue;

  const HpBar({super.key, required this.value, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Health $value/$maxValue', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.onSurface.withAlpha(31),
          ),
        ),
      ],
    );
  }
}
