import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  const StatRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final progress = (value.clamp(0, 100) / 100).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 96, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(value: progress),
          ),
          const SizedBox(width: 12),
          Text(value.toString().padLeft(2, '0')),
        ],
      ),
    );
  }
}
