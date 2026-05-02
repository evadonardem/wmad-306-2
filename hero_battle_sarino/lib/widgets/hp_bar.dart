import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  const HpBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
    this.height = 20,
  });

  final int currentHp;
  final int maxHp;
  final double height;

  @override
  Widget build(BuildContext context) {
    final percentage = currentHp / maxHp;
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: LinearProgressIndicator(
        value: percentage,
        backgroundColor: Colors.red.shade200,
        valueColor: AlwaysStoppedAnimation<Color>(
          percentage > 0.5 ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}