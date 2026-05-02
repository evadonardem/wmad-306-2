import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final int statValue = int.tryParse(value) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: statValue / 100,
          color: color,
          backgroundColor: Colors.grey[300],
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }
}