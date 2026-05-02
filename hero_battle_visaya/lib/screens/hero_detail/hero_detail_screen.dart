import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/stat_row.dart';

class HeroDetailScreen extends StatelessWidget {
  const HeroDetailScreen({super.key, required this.hero});

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

  // ─── Reusable Widgets ────────────────────────────────────────────────────────

  Widget _buildHeroImage() {
    // Tier 1: Try Superhero API URL if valid
    final apiUrl = _isValidUrl(hero.imageUrl) ? hero.imageUrl : null;
    // Tier 2: Fall back to CDN-constructed URL
    final cdnUrl = _cdnHeroImageUrl();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Builder(
              builder: (context) {
                final scheme = Theme.of(context).colorScheme;
                return ColoredBox(
                  color: scheme.surface,
                  child: apiUrl != null
                      ? Image.network(
                          apiUrl,
                          fit: BoxFit.contain,
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
              },
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Consumer<DeckProvider>(
              builder: (context, deck, child) {
                final inDeck = deck.contains(hero);
                return Material(
                  color: Colors.transparent,
                  child: Tooltip(
                    message: inDeck ? 'Remove from Deck' : 'Add to Deck',
                    child: IconButton.filledTonal(
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF9B5CFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                      onPressed: inDeck
                          ? () => deck.removeHero(hero)
                          : deck.isFull
                              ? null
                              : () => deck.addHero(hero),
                      icon: Icon(inDeck ? Icons.remove : Icons.add),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCdnImage() {
    return Image.network(
      _cdnHeroImageUrl(),
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildDiceBearAvatar(),
    );
  }

  /// Shown when the primary Superhero API image fails to load.
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

  /// Last-resort placeholder — shown only when every network source fails.
  Widget _buildInitialPlaceholder() {
    final initial = hero.name.isEmpty ? '?' : hero.name[0];
    return Center(
      child: Text(
        initial,
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPowerStatBar({
    required BuildContext context,
    required String label,
    required int value,
  }) {
    final clamped = value.clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ),
              Text('$value', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: clamped / 100,
            minHeight: 6,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13)),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataHeader(BuildContext context) {
    final publisher = hero.publisher.isEmpty ? 'Unknown' : hero.publisher;
    final isGood = hero.alignment.toLowerCase() == 'good';
    final isBad = hero.alignment.toLowerCase() == 'bad';
    final alignColor = isGood ? Colors.green : isBad ? Colors.red : Theme.of(context).colorScheme.secondary;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: publisher,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: ' - ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextSpan(
                    text: hero.alignment[0].toUpperCase() + hero.alignment.substring(1),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: alignColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              primary: true,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroImage(),
                  _buildMetadataHeader(context),
                  const SizedBox(height: 6),

                    _buildSectionCard(
                      context: context,
                      title: 'Profile',
                      children: [
                        StatRow(
                          label: 'Full Name',
                          value: hero.fullName.isEmpty ? 'Unknown' : hero.fullName,
                        ),
                        StatRow(label: 'Hero ID', value: hero.id),
                      ],
                    ),
                    const SizedBox(height: 6),

                    _buildSectionCard(
                      context: context,
                      title: 'Battle Stats',
                      children: [
                        StatRow(label: 'HP', value: '${hero.maxHp}'),
                        StatRow(label: 'Attack', value: '${hero.attack}'),
                        StatRow(label: 'Special Attack', value: '${hero.specialAttack}'),
                        StatRow(label: 'Defense', value: '${hero.defense}'),
                        StatRow(label: 'Initiative', value: '${hero.initiative}'),
                      ],
                    ),
                    const SizedBox(height: 6),

                    _buildSectionCard(
                      context: context,
                      title: 'Power Stats',
                      children: [
                        _buildPowerStatBar(
                          context: context,
                          label: 'Intelligence',
                          value: hero.powerStats.intelligence,
                        ),
                        _buildPowerStatBar(
                          context: context,
                          label: 'Strength',
                          value: hero.powerStats.strength,
                        ),
                        _buildPowerStatBar(
                          context: context,
                          label: 'Speed',
                          value: hero.powerStats.speed,
                        ),
                        _buildPowerStatBar(
                          context: context,
                          label: 'Durability',
                          value: hero.powerStats.durability,
                        ),
                        _buildPowerStatBar(
                          context: context,
                          label: 'Power',
                          value: hero.powerStats.power,
                        ),
                        _buildPowerStatBar(
                          context: context,
                          label: 'Combat',
                          value: hero.powerStats.combat,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}