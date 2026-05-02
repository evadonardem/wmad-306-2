import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  final int current;
  final int max;
  final Color? color;
  final double height;
  final bool showLabel;

  const HpBar({
    super.key,
    required this.current,
    required this.max,
    this.color,
    this.height = 12,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = max == 0 ? 0.0 : (current / max).clamp(0.0, 1.0);
    final barColor = color ?? _colorForRatio(ratio);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HP',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '$current / $max',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        if (showLabel) const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: ratio),  // animate from 0 → current
          duration: const Duration(milliseconds: 400),
          builder: (_, value, __) => ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: LinearProgressIndicator(
              value: value,
              minHeight: height,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
      ],
    );
  }

  Color _colorForRatio(double ratio) {
    if (ratio > 0.5) return Colors.greenAccent;
    if (ratio > 0.25) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}