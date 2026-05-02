import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String label;
  final int value;

  const StatRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: LinearProgressIndicator(
                value: value > 100 ? 1.0 : value / 100,
                minHeight: 8,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              value.toString(),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
