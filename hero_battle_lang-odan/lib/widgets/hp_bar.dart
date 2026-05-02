import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  const HpBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
    required this.color,
  });

  final int currentHp;
  final int maxHp;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final safeCurrent = currentHp.clamp(0, maxHp);
    final value = maxHp == 0 ? 0.0 : safeCurrent / maxHp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$safeCurrent / $maxHp HP'),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: value),
          duration: const Duration(milliseconds: 600),
          builder: (context, animatedValue, child) {
            return LinearProgressIndicator(
              value: animatedValue,
              minHeight: 10,
              color: color,
              backgroundColor: color.withValues(alpha: 0.2),
            );
          },
        ),
      ],
    );
  }
}
