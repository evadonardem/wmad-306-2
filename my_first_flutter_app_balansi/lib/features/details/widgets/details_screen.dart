import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/pokemon_detail.dart';
import '../../../core/theme/pokemon_type_color.dart';
import '../../../core/utils/id_padding.dart';
import '../../../core/utils/string_ext.dart';
import '../../favorites/widgets/favorite_heart_button.dart';
import '../providers/pokemon_detail_provider.dart';
import 'detail_skeleton.dart';
import 'stat_bar.dart';
import 'type_pill.dart';

/// Pokémon detail screen — hero artwork, types, specs, base stats.
class DetailsScreen extends ConsumerWidget {
  const DetailsScreen({super.key, required this.pokemonId});

  final int pokemonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(pokemonDetailProvider(pokemonId));

    return Scaffold(
      body: detail.when(
        loading: () => const SafeArea(child: DetailSkeleton()),
        error: (e, _) => SafeArea(
          child: _DetailError(
            message: e.toString().replaceFirst('Exception: ', ''),
            onRetry: () => ref.invalidate(pokemonDetailProvider(pokemonId)),
          ),
        ),
        data: (d) => _DetailBody(detail: d),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  final PokemonDetail detail;

  @override
  Widget build(BuildContext context) {
    final accent = PokemonTypeColor.of(detail.primaryType);
    final pastel = PokemonTypeColor.pastel(detail.primaryType);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [pastel, Colors.white],
          stops: const [0.0, 0.55],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Spacer(),
                  FavoriteHeartButton(pokemonId: detail.id, color: accent),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.name.toTitleCase(),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final t in detail.types) TypePill(type: t),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatPokedexId(detail.id),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withValues(alpha: 0.18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Hero(
                  tag: 'pokemon-${detail.id}',
                  child: SizedBox(
                    height: 260,
                    child: detail.artworkUrl != null
                        ? Image.network(detail.artworkUrl!, fit: BoxFit.contain)
                        : const Icon(Icons.catching_pokemon,
                            size: 120, color: Colors.black26),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _GlassCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _Spec(
                          label: 'Height',
                          value: '${detail.heightMeters.toStringAsFixed(1)} m',
                        ),
                        _Divider(),
                        _Spec(
                          label: 'Weight',
                          value: '${detail.weightKg.toStringAsFixed(1)} kg',
                        ),
                        _Divider(),
                        _Spec(
                          label: 'Abilities',
                          value: detail.abilities.length.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),
              const SizedBox(height: 14),
              _SectionTitle('Abilities'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in detail.abilities)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Text(
                        a.toTitleCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 80.ms),
              const SizedBox(height: 18),
              _SectionTitle('Base stats'),
              _GlassCard(
                child: Column(
                  children: [
                    for (final s in detail.stats)
                      StatBar(stat: s, color: accent),
                  ],
                ),
              ).animate().fadeIn(duration: 450.ms, delay: 120.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: Colors.black12,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 0, 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 56, color: Colors.black38),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
