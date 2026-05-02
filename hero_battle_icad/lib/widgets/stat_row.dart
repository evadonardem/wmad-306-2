import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const StatRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: $value"),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 100, // API stats are 0-100 [cite: 137-142]
            color: color,
            backgroundColor: color.withOpacity(0.2),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}