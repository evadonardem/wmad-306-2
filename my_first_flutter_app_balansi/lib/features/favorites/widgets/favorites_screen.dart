import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routes.dart';
import '../../pokedex/providers/pokedex_list_provider.dart';
import '../../pokedex/widgets/pokemon_grid_card.dart';
import '../providers/favorites_provider.dart';

/// Shows only Pokémon flagged as favorite.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoritesProvider);
    final list = ref.watch(pokedexListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (all) {
          final favs = all.where((p) => favIds.contains(p.id)).toList();
          if (favs.isEmpty) return const _EmptyState();
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: favs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, i) {
              final p = favs[i];
              return PokemonGridCard(
                summary: p,
                index: i,
                onTap: () => Navigator.pushNamed(
                  context,
                  Routes.details,
                  arguments: p.id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.black.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap the heart on any Pokémon to save it here.',
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
