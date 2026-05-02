import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  final int current;
  final int max;
  final String label;
  final Color? color;

  const HpBar({
    super.key,
    required this.current,
    required this.max,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = max > 0 ? current / max : 0.0;
    final barColor = color ?? _getHpColor(percentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$current/$max',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getHpColor(double percentage) {
    if (percentage > 0.6) return Colors.green;
    if (percentage > 0.3) return Colors.orange;
    return Colors.red;
  }
}