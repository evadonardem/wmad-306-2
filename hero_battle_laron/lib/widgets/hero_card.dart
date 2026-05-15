import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/hero_model.dart';

class HeroCard extends StatelessWidget {
  final HeroModel hero;
  final VoidCallback? onTap;

  const HeroCard({super.key, required this.hero, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CachedNetworkImage(
                imageUrl: hero.image.url,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hero.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Intelligence: ${hero.powerstats.intelligence}'),
                    Text('Strength: ${hero.powerstats.strength}'),
                    Text('Speed: ${hero.powerstats.speed}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}