import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/hero_model.dart';

class HeroPortrait extends StatelessWidget {
  const HeroPortrait({
    super.key,
    required this.hero,
    this.height,
    this.fit = BoxFit.cover,
    this.showPowerBadge = false,
  });

  final HeroModel hero;
  final double? height;
  final BoxFit fit;
  final bool showPowerBadge;

  static const _headers = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Mobile Safari/537.36',
    'Accept':
        'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
  };

  @override
  Widget build(BuildContext context) {
    final imageUrl = hero.imageUrl.trim();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isEmpty)
            _FallbackPortrait(hero: hero)
          else
            CachedNetworkImage(
              imageUrl: imageUrl,
              httpHeaders: _headers,
              fit: fit,
              placeholder: (_, _) =>
                  _FallbackPortrait(hero: hero, loading: true),
              errorWidget: (_, _, _) => _FallbackPortrait(hero: hero),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x66000000),
                  Color(0xCC000000),
                ],
                stops: [0.45, 0.75, 1],
              ),
            ),
          ),
          if (showPowerBadge)
            Positioned(
              top: 10,
              right: 10,
              child: _PowerBadge(value: hero.attack + hero.specialAttack),
            ),
        ],
      ),
    );
  }
}

class _FallbackPortrait extends StatelessWidget {
  const _FallbackPortrait({required this.hero, this.loading = false});

  final HeroModel hero;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(hero.id);
    final initial = hero.name.trim().isEmpty ? '?' : hero.name.trim()[0];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -20,
            child: Icon(
              Icons.bolt,
              size: 132,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -24,
            child: Icon(
              Icons.shield,
              size: 128,
              color: Colors.black.withValues(alpha: 0.16),
            ),
          ),
          Center(
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : Container(
                    width: 92,
                    height: 92,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.24),
                      border: Border.all(color: Colors.white70, width: 2),
                    ),
                    child: Text(
                      initial.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Color> _colorsFor(String id) {
    final value = int.tryParse(id) ?? id.hashCode;
    final palettes = [
      [const Color(0xFF111827), const Color(0xFF06B6D4)],
      [const Color(0xFF1F2937), const Color(0xFFEF4444)],
      [const Color(0xFF0F172A), const Color(0xFF22C55E)],
      [const Color(0xFF18181B), const Color(0xFFF59E0B)],
      [const Color(0xFF082F49), const Color(0xFFE11D48)],
    ];
    return palettes[value.abs() % palettes.length];
  }
}

class _PowerBadge extends StatelessWidget {
  const _PowerBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Color(0x66000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        value.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
