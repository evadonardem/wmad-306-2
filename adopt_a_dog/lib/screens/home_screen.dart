import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../providers/dogs_provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/dog_card.dart';
import '../widgets/filter_pill.dart';
import 'dog_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dogs = context.watch<DogsProvider>();
    final favs = context.watch<FavoritesProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.forest,
          onRefresh: () => dogs.load(refresh: true),
          child: CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              SliverToBoxAdapter(child: _header(context, dogs)),
              SliverToBoxAdapter(child: _filters(context, dogs)),
              _grid(context, dogs, favs),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, DogsProvider dogs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.forest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pets, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                'PawMatch',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.forest,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Find your\nfurever friend.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            onChanged: dogs.setQuery,
            decoration: InputDecoration(
              hintText: 'Search by name or breed',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.inkSoft),
              suffixIcon: _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, color: AppColors.inkSoft),
                      onPressed: () {
                        _searchCtrl.clear();
                        dogs.setQuery('');
                        setState(() {});
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context, DogsProvider dogs) {
    if (dogs.filters.isEmpty) return const SizedBox(height: 60);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                const Text(
                  'Perfect Match',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const Spacer(),
                if (dogs.activeFilters.isNotEmpty)
                  TextButton(
                    onPressed: dogs.clearFilters,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.terracotta,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: dogs.filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = dogs.filters[i];
                return FilterPill(
                  label: f,
                  active: dogs.activeFilters.contains(f),
                  onTap: () => dogs.toggleFilter(f),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(BuildContext context, DogsProvider dogs, FavoritesProvider favs) {
    if (dogs.state == LoadState.loading && dogs.all.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.forest),
        ),
      );
    }
    if (dogs.state == LoadState.error && dogs.all.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _errorState(dogs),
      );
    }

    final list = dogs.visible;
    if (list.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyState(),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final cols = width >= 720 ? 3 : 2;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate(
          childCount: list.length,
          (context, i) {
            final dog = list[i];
            // The "Perfect Match" rearrangement: cards animate in/out as the
            // filter set changes, since `visible` shrinks/grows.
            return AnimationConfiguration.staggeredGrid(
              position: i,
              columnCount: cols,
              duration: const Duration(milliseconds: 420),
              child: ScaleAnimation(
                scale: 0.92,
                child: FadeInAnimation(
                  child: DogCard(
                    key: ValueKey(dog.id),
                    dog: dog,
                    isFavorite: favs.isFavorite(dog.id),
                    onToggleFavorite: () => favs.toggle(dog.id),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DogDetailScreen(
                          id: dog.id,
                          summary: dog,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _errorState(DogsProvider dogs) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: AppColors.inkSoft),
          const SizedBox(height: 12),
          const Text(
            "Couldn't load dogs",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            dogs.error ?? 'Please check your connection.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.inkSoft),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => dogs.load(refresh: true),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.inkSoft),
          SizedBox(height: 12),
          Text(
            'No matches yet',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          SizedBox(height: 4),
          Text(
            'Try a different filter or search term.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
