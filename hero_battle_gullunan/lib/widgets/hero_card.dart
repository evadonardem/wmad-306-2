import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/hero_model.dart';
import '../router/app_router.dart';

class HeroCard extends StatelessWidget {
  final HeroModel hero;
  final bool showDeckAction;
  final bool isInDeck;
  final VoidCallback? onAction;

  const HeroCard({
    required this.hero,
    this.showDeckAction = false,
    this.isInDeck = false,
    this.onAction,
    super.key,
  });

  Color get _borderColor {
    switch (hero.rarity) {
      case HeroRarity.legendary:
        return const Color(0xFFFFD700);
      case HeroRarity.epic:
        return const Color(0xFF7B2FBE);
      case HeroRarity.rare:
        return const Color(0xFF3A8FFF);
      case HeroRarity.common:
        return const Color(0xFF8E8E8E);
    }
  }

  Gradient get _borderGradient {
    switch (hero.rarity) {
      case HeroRarity.legendary:
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case HeroRarity.epic:
        return const LinearGradient(
          colors: [Color(0xFF964BFF), Color(0xFF5F3DC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case HeroRarity.rare:
        return const LinearGradient(
          colors: [Color(0xFF4DA6FF), Color(0xFF3A8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case HeroRarity.common:
        return const LinearGradient(
          colors: [Color(0xFF7A7A7A), Color(0xFF545454)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  String get _actionLabel => isInDeck ? 'Remove from Deck' : 'Add to Deck';
  IconData get _actionIcon => isInDeck ? Icons.close : Icons.add;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
            context,
            RouteNames.heroDetail,
            arguments: hero,
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _borderColor.withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 0.72,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: hero.imageUrl.isNotEmpty
                        ? Image.network(
                            hero.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[850],
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 48),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[850],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 48),
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: _borderGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        hero.rarity.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hero.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            fontSize: 16,
                          ),
                        ),
                        if (showDeckAction) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: onAction,
                              icon: Icon(_actionIcon, size: 18),
                              label: Text(_actionLabel),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _borderColor.withValues(alpha: isInDeck ? 0.12 : 0.18),
                                foregroundColor: Colors.white,
                                shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
