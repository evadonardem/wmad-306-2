import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color? valueColor;

  const StatRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // Value bar background
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  // Value bar fill
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (value / 100.0).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: valueColor ?? _getStatColor(value),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Value text
                  Center(
                    child: Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getContrastColor(value),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatColor(int value) {
    if (value >= 80) return Colors.purple;
    if (value >= 60) return Colors.blue;
    if (value >= 40) return Colors.green;
    if (value >= 20) return Colors.orange;
    return Colors.red;
  }

  Color _getContrastColor(int value) {
    // Return white text for dark bars, black for light bars
    if (value >= 60) return Colors.white;
    return Colors.black;
  }
}