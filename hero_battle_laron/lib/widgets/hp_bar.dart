import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  final double currentHp;
  final double maxHp;

  const HpBar({super.key, required this.currentHp, required this.maxHp});

  @override
  Widget build(BuildContext context) {
    double percentage = currentHp / maxHp;
    return Column(
      children: [
        Text('HP: ${currentHp.toInt()}/${maxHp.toInt()}'),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.red[100],
          valueColor: AlwaysStoppedAnimation<Color>(percentage > 0.5 ? Colors.green : Colors.red),
        ),
      ],
    );
  }
}