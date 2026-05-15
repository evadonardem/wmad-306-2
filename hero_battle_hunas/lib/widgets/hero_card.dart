import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/hero_model.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.hero,
    this.trailing,
    this.onTap,
  });

  final HeroModel hero;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 86,
              height: 104,
              child: hero.imageUrl.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : CachedNetworkImage(
                      imageUrl: hero.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, _, _) => const Icon(Icons.person),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hero.publisher ?? hero.fullName ?? 'Unknown origin',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text('Battle score ${hero.battleScore}'),
                  ],
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
