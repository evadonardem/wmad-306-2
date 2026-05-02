import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
	const StatRow({
		super.key,
		required this.label,
		required this.value,
	});

	final String label;
	final String value;

	@override
	Widget build(BuildContext context) {
		final textTheme = Theme.of(context).textTheme;

		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 4),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Expanded(
						child: Text(
							label,
							style: textTheme.bodyMedium,
						),
					),
					const SizedBox(width: 12),
					Flexible(
						child: Text(
							value,
							textAlign: TextAlign.right,
							style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
						),
					),
				],
			),
		);
	}
}
