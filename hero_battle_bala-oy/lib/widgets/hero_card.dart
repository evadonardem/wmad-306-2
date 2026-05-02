import 'package:flutter/material.dart';

import '../models/hero_model.dart';
import 'hero_image.dart';

class HeroCard extends StatelessWidget {
	const HeroCard({
		super.key,
		required this.hero,
		required this.onTap,
		this.trailing,
	});

	final HeroModel hero;
	final VoidCallback onTap;
	final Widget? trailing;

	@override
	Widget build(BuildContext context) {
		final urls = hero.displayImageCandidates;

		return Card(
			clipBehavior: Clip.antiAlias,
			child: InkWell(
				onTap: onTap,
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: <Widget>[
						Expanded(
							child: HeroImage(
								urls: urls,
								heroId: hero.id,
								heroName: hero.name,
								searchTerms: hero.imageSearchTerms,
								fit: BoxFit.cover,
								loading: const Center(
									child: CircularProgressIndicator(strokeWidth: 2),
								),
								error: const ColoredBox(
									color: Colors.black12,
									child: Icon(Icons.broken_image, size: 48),
								),
							),
						),
						Padding(
							padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
							child: Row(
								children: <Widget>[
									Expanded(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: <Widget>[
												Text(
													hero.name,
													maxLines: 1,
													overflow: TextOverflow.ellipsis,
													style: Theme.of(context).textTheme.titleSmall,
												),
												Text(
													hero.publisher,
													maxLines: 1,
													overflow: TextOverflow.ellipsis,
													style: Theme.of(context).textTheme.bodySmall,
												),
											],
										),
									),
									trailing ?? const SizedBox.shrink(),
								],
							),
						),
					],
				),
			),
		);
	}
}

