import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String label;
  final int value;

  const StatRow({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (value.clamp(0, 100)) / 100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
