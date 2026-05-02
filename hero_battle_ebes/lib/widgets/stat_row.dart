import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;

  const StatRow({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 100,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (value / maxValue).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(letterSpacing: 0.5),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: ratio),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (_, value, __) => LinearProgressIndicator(
                  value: value,
                  minHeight: 9,
                  backgroundColor: Colors.white10,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_colorForLabel(label)),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForLabel(String label) {
    return switch (label.toLowerCase()) {
      'intelligence' => Colors.blueAccent,
      'strength' => Colors.redAccent,
      'speed' => Colors.yellowAccent,
      'durability' => Colors.greenAccent,
      'power' => Colors.purpleAccent,
      'combat' => Colors.orangeAccent,
      _ => Colors.grey,
    };
  }
}
