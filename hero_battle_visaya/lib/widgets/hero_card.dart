import 'package:flutter/material.dart';

import '../models/hero_model.dart';
import '../router/app_router.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.hero});

  final HeroModel hero;

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String _slugify(String value) {
    final lower = value.toLowerCase();
    final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return replaced.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String _cdnHeroImageUrl() {
    final slug = _slugify(hero.name);
    if (hero.id.isEmpty || slug.isEmpty) return '';
    return 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/${hero.id}-$slug.jpg';
  }

  String _diceBearFallbackUrl() {
    final seed = hero.name.isNotEmpty ? hero.name : 'hero';
    return 'https://api.dicebear.com/9.x/bottts/avif?seed=${Uri.encodeComponent(seed)}';
  }

  /// Returns true only if the URL is a non-empty, valid http/https string.
  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  // ─── Widgets ─────────────────────────────────────────────────────────────────

  Widget _buildImage() {
    // Tier 1: Try Superhero API URL if valid
    final apiUrl = _isValidUrl(hero.imageUrl) ? hero.imageUrl : null;
    // Tier 2: Fall back to CDN-constructed URL
    final cdnUrl = _cdnHeroImageUrl();

    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0x22000000)),
      child: apiUrl != null
          ? Image.network(
              apiUrl,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  cdnUrl.isNotEmpty ? _buildCdnImage() : _buildDiceBearAvatar(),
            )
          : (cdnUrl.isNotEmpty ? _buildCdnImage() : _buildDiceBearAvatar()),
    );
  }

  Widget _buildCdnImage() {
    return Image.network(
      _cdnHeroImageUrl(),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildDiceBearAvatar(),
    );
  }

  Widget _buildDiceBearAvatar() {
    return Image.network(
      _diceBearFallbackUrl(),
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (_, __, ___) => _buildInitialPlaceholder(),
    );
  }

  Widget _buildInitialPlaceholder() {
    final initial = hero.name.isEmpty ? '?' : hero.name[0];
    return Center(
      child: Text(
        initial,
        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          RouteNames.heroDetail,
          arguments: hero,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildImage()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hero.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ATK ${hero.attack} • HP ${hero.maxHp}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}