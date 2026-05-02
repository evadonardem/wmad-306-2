import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/hero_image.dart';

class HeroDetailScreen extends StatelessWidget {
  const HeroDetailScreen({
    super.key,
    required this.hero,
    this.alreadyInDeckFromSource = false,
  });

  final HeroModel hero;
  final bool alreadyInDeckFromSource;

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckProvider>();
    final inDeck = alreadyInDeckFromSource || deck.contains(hero);
    final urls = hero.displayImageCandidates;
    final theme = Theme.of(context);
    final title = hero.fullName.isEmpty ? hero.name : hero.fullName;
    final alignmentLabel = hero.alignment.isEmpty ? 'neutral' : hero.alignment;
    final hasPublisher = hero.publisher.trim().isNotEmpty;
    final altEgos = hero.alterEgos.trim();
    final statEntries = <_HeroStatEntry>[
      _HeroStatEntry(
        label: 'Intelligence',
        value: hero.powerStats.intelligence,
      ),
      _HeroStatEntry(label: 'Strength', value: hero.powerStats.strength),
      _HeroStatEntry(label: 'Speed', value: hero.powerStats.speed),
      _HeroStatEntry(label: 'Durability', value: hero.powerStats.durability),
      _HeroStatEntry(label: 'Power', value: hero.powerStats.power),
      _HeroStatEntry(label: 'Combat', value: hero.powerStats.combat),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              elevation: 10,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Stack(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 16 / 11,
                    child: HeroImage(
                      urls: urls,
                      heroId: hero.id,
                      heroName: hero.name,
                      searchTerms: hero.imageSearchTerms,
                      fit: BoxFit.cover,
                      loading: const ColoredBox(
                        color: Colors.black26,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: const ColoredBox(
                        color: Colors.black12,
                        child: Center(
                          child: Icon(Icons.broken_image_outlined, size: 72),
                        ),
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
                            Colors.black.withValues(alpha: 0.05),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.85),
                          ],
                          stops: const [0, 0.55, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: _Pill(
                      icon: inDeck ? Icons.verified : Icons.star_border,
                      label: inDeck ? 'In Deck' : 'Available',
                      backgroundColor: inDeck
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface.withValues(alpha: 0.88),
                      foregroundColor: inDeck
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 0.95,
                            shadows: const [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black87,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            _Pill(
                              icon: Icons.local_fire_department_outlined,
                              label: hero.name,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.14,
                              ),
                              foregroundColor: Colors.white,
                            ),
                            _Pill(
                              icon: Icons.shield_outlined,
                              label: alignmentLabel,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.14,
                              ),
                              foregroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.65,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Hero profile',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (hasPublisher)
                      _InfoRow(
                        icon: Icons.apartment_outlined,
                        label: 'Publisher',
                        value: hero.publisher,
                      ),
                    _InfoRow(
                      icon: Icons.bolt_outlined,
                      label: 'Alignment',
                      value: alignmentLabel,
                    ),
                    if (hero.fullName.trim().isNotEmpty)
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Full name',
                        value: hero.fullName,
                      ),
                    if (altEgos.isNotEmpty && altEgos != 'No alter egos found.')
                      _InfoRow(
                        icon: Icons.switch_account_outlined,
                        label: 'Alter egos',
                        value: altEgos,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Power stats',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          'Battle ready',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final tileWidth = (constraints.maxWidth - 12) / 2;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: statEntries
                              .map(
                                (entry) => SizedBox(
                                  width: tileWidth,
                                  child: _StatTile(
                                    label: entry.label,
                                    value: entry.value,
                                    accent: theme.colorScheme.primary,
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: inDeck
                  ? null
                  : () {
                      context.read<DeckProvider>().addHero(hero);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(milliseconds: 1200),
                          content: Text('${hero.name} added to deck'),
                        ),
                      );
                    },
              icon: Icon(
                inDeck ? Icons.check_circle_outline : Icons.add_circle_outline,
              ),
              label: Text(inDeck ? 'Already in Deck' : 'Add to Deck'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStatEntry {
  const _HeroStatEntry({required this.label, required this.value});

  final String label;
  final int value;
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: foregroundColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (value.clamp(0, 100)) / 100.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                value.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }
}
