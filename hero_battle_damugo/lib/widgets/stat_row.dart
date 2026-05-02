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
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 4),
			child: Row(
				children: <Widget>[
					Expanded(
						child: Text(
							label,
							style: Theme.of(context).textTheme.bodyMedium,
						),
					),
					Text(
						value,
						style: Theme.of(context).textTheme.titleSmall,
					),
				],
			),
		);
	}
}

