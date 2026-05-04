import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/hero_model.dart';
import '../router/app_router.dart';

class HeroCard extends StatelessWidget {
	const HeroCard({super.key, required this.hero});

	final HeroModel hero;

	@override
	Widget build(BuildContext context) {
		return Card(
			clipBehavior: Clip.antiAlias,
			margin: const EdgeInsets.all(8),
			child: InkWell(
				onTap: () => Navigator.pushNamed(
					context,
					RouteNames.heroDetail,
					arguments: hero,
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Expanded(
							child: DecoratedBox(
								decoration: const BoxDecoration(color: Color(0x22000000)),
								child: hero.imageUrl.isEmpty
										? const Center(child: Icon(Icons.person, size: 36))
										: CachedNetworkImage(
												imageUrl: hero.imageUrl,
												fit: BoxFit.contain,
												filterQuality: FilterQuality.high,
												placeholder: (context, url) => const Center(
													child: CircularProgressIndicator(strokeWidth: 2),
												),
												errorWidget: (context, url, error) => Center(
													child: Text(
														hero.name.isEmpty ? '?' : hero.name[0],
														style: const TextStyle(
															fontSize: 36,
															fontWeight: FontWeight.bold,
														),
													),
												),
											),
							),
						),
						Padding(
							padding: const EdgeInsets.all(8),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										hero.name,
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
										style: Theme.of(context).textTheme.titleSmall,
									),
									const SizedBox(height: 4),
									Text('ATK ${hero.attack} • HP ${hero.maxHp}'),
								],
							),
						),
					],
				),
			),
		);
	}
}
