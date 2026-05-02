import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/hero_model.dart';

class HeroCard extends StatelessWidget {
  final HeroModel hero;
  final bool selected;
  final VoidCallback? onTap;

  const HeroCard({
    super.key,
    required this.hero,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: selected ? 6 : 2,
      color: selected ? Theme.of(context).colorScheme.secondaryContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: hero.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.black12,
                    child: const Center(child: Icon(Icons.error_outline)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hero.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(hero.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
