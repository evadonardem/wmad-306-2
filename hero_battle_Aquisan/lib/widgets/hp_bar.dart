import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  final int hp;
  final int maxHp;
  final Color color;
  final double height;
  final double width;

  const HpBar({
    super.key,
    required this.hp,
    required this.maxHp,
    required this.color,
    this.height = 10.0,
    this.width = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the percentage, ensuring it stays between 0.0 and 1.0
    final double percentage = maxHp > 0 ? (hp / maxHp).clamp(0.0, 1.0) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$hp / $maxHp HP',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}