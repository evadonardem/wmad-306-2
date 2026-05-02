import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  const HpBar({
    super.key,
    required this.label,
    required this.current,
    required this.max,
  });

  final String label;
  final int current;
  final int max;

  @override
  Widget build(BuildContext context) {
    final safeMax = max <= 0 ? 1 : max;
    final value = (current / safeMax).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label HP: $current/$max'),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}
