import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routes.dart';
import '../providers/pokedex_list_provider.dart';
import '../providers/search_query_provider.dart';
import 'grid_skeleton.dart';
import 'pokemon_grid_card.dart';

/// Home screen — search bar + 2-col grid of Pokémon, FAB to favorites.
class PokedexScreen extends ConsumerWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredPokedexProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(pokedexListProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: _Header()),
              const SliverToBoxAdapter(child: _SearchField()),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              filtered.when(
                loading: () => const SliverFillRemaining(child: GridSkeleton()),
                error: (e, _) => SliverFillRemaining(
                  child: _ErrorView(
                    message: e.toString().replaceFirst('Exception: ', ''),
                    onRetry: () => ref.invalidate(pokedexListProvider),
                  ),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text('No Pokémon match your search.')),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final p = list[i];
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
                        childCount: list.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, Routes.favorites),
        icon: const Icon(Icons.favorite),
        label: const Text('Favorites'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pokédex', style: theme.textTheme.displaySmall ??
              theme.textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(
            'Generations 1–6 · 721 Pokémon',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: TextField(
        onChanged: (v) =>
            ref.read(searchQueryProvider.notifier).state = v,
        decoration: const InputDecoration(
          hintText: 'Search by name or #id',
          prefixIcon: Icon(Icons.search, color: Colors.black38),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

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
            const Icon(Icons.cloud_off, size: 56, color: Colors.black38),
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
