import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  final int current;
  final int max;

  const HpBar({super.key, required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final percentage = max == 0 ? 0.0 : current / max;
    final color = percentage > 0.5
        ? Colors.green
        : percentage > 0.25
            ? Colors.orange
            : Colors.red;

    return SizedBox(
      width: 100,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 16,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Text('$current / $max',
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
