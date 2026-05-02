import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/hero_model.dart';
import '../router/app_router.dart';

class HeroCard extends StatelessWidget {
  final HeroModel hero;
  final VoidCallback? onTap;

  const HeroCard({super.key, required this.hero, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () => Navigator.pushNamed(
                context,
                RouteNames.heroDetail,
                arguments: hero,
              ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Hero image ───────────────────────────────────────────────
            CachedNetworkImage(
              imageUrl: hero.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: const Color(0xFF1A1A2E),
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFF1A1A2E),
                child:
                    const Center(child: Icon(Icons.person, size: 56)),
              ),
            ),

            // ── Gradient overlay ─────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.92),
                  ],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),

            // ── Text info ────────────────────────────────────────────────
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hero.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: [Shadow(blurRadius: 4)],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hero.publisher.isNotEmpty)
                    Text(
                      hero.publisher,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 11),
                    ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _AlignmentBadge(alignment: hero.alignment),
                      const Spacer(),
                      _StatChip(icon: '⚔️', value: hero.attack),
                      const SizedBox(width: 4),
                      _StatChip(icon: '🛡️', value: hero.defense),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.95, 0.95), duration: 300.ms);
  }
}

class _AlignmentBadge extends StatelessWidget {
  final String alignment;
  const _AlignmentBadge({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (alignment) {
      'good' => (Colors.blueAccent, 'Hero'),
      'bad' => (Colors.redAccent, 'Villain'),
      _ => (Colors.grey, 'Neutral'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.85),
          borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final int value;
  const _StatChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) => Text(
        '$icon $value',
        style:
            const TextStyle(color: Colors.white70, fontSize: 11),
      );
}
