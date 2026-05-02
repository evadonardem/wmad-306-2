import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
	const HpBar({
		super.key,
		required this.currentHp,
		required this.maxHp,
		this.height = 12,
	});

	final int currentHp;
	final int maxHp;
	final double height;

	@override
	Widget build(BuildContext context) {
		final safeMax = maxHp <= 0 ? 1 : maxHp;
		final ratio = (currentHp / safeMax).clamp(0.0, 1.0);

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				ClipRRect(
					borderRadius: BorderRadius.circular(999),
					child: LinearProgressIndicator(
						value: ratio,
						minHeight: height,
						backgroundColor: Colors.grey.shade300,
						color: ratio > 0.5
								? Colors.green
								: ratio > 0.25
										? Colors.orange
										: Colors.red,
					),
				),
				const SizedBox(height: 4),
				Text('HP: $currentHp / $safeMax'),
			],
		);
	}
}
