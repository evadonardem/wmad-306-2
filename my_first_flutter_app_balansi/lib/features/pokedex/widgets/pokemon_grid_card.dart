import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/pokemon_summary.dart';
import '../../../core/theme/pokemon_type_color.dart';
import '../../../core/utils/id_padding.dart';
import '../../../core/utils/string_ext.dart';
import '../../details/providers/pokemon_detail_provider.dart';

/// Single Pokémon tile in the home grid. Renders a glass card backed by the
/// pastel of the primary type once detail data resolves.
class PokemonGridCard extends ConsumerWidget {
  const PokemonGridCard({
    super.key,
    required this.summary,
    required this.onTap,
    required this.index,
  });

  final PokemonSummary summary;
  final VoidCallback onTap;
  final int index;

  /// Lightweight artwork URL — derived from the official artwork CDN to avoid
  /// loading every detail upfront.
  String get _artworkUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${summary.id}.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Best-effort type lookup — only colors the card if detail is already cached.
    final detail = ref.watch(pokemonDetailProvider(summary.id));
    final accent = detail.maybeWhen(
      data: (d) => PokemonTypeColor.of(d.primaryType),
      orElse: () => PokemonTypeColor.of('normal'),
    );
    final pastel = detail.maybeWhen(
      data: (d) => PokemonTypeColor.pastel(d.primaryType),
      orElse: () => Colors.white.withValues(alpha: 0.85),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: pastel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatPokedexId(summary.id),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black.withValues(alpha: 0.45),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              summary.name.toTitleCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'pokemon-${summary.id}',
                  child: Image.network(
                    _artworkUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.catching_pokemon,
                      size: 56,
                      color: Colors.black26,
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(
            duration: 320.ms,
            delay: Duration(milliseconds: 30 * (index % 12)),
          )
          .slideY(begin: 0.05, curve: Curves.easeOutCubic),
    );
  }
}
