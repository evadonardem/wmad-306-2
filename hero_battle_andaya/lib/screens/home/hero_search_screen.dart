import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../models/hero_model.dart';
import '../../router/app_router.dart';

class HeroSearchScreen extends StatefulWidget {
  const HeroSearchScreen({Key? key}) : super(key: key);

  @override
  State<HeroSearchScreen> createState() => _HeroSearchScreenState();
}

class _HeroSearchScreenState extends State<HeroSearchScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocus;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _clearSearch(HeroSearchProvider provider) {
    _searchController.clear();
    provider.clearSearch();
  }

  void _handleSearch(String query, HeroSearchProvider provider) {
    if (query.isEmpty) {
      provider.clearSearch();
    } else {
      provider.searchHeroes(query);
    }
  }

  void _navigateToHeroDetail(BuildContext context, HeroModel hero) {
    Navigator.pushNamed(
      context,
      RouteNames.heroDetail,
      arguments: hero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Characters'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<HeroSearchProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSearchInput(provider, context),
                const SizedBox(height: 16),
                _buildActionButtons(provider, context),
                const SizedBox(height: 16),
                _buildContent(provider, context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchInput(HeroSearchProvider provider, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: (value) => _handleSearch(value, provider),
        decoration: InputDecoration(
          hintText: 'Search by hero name...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _clearSearch(provider),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    HeroSearchProvider provider,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await provider.getRandomHero();
                if (provider.selectedHero != null && mounted) {
                  _navigateToHeroDetail(context, provider.selectedHero!);
                }
              },
              icon: const Icon(Icons.shuffle),
              label: const Text('Random Character'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => provider.getRandomHeroes(count: 10),
              icon: const Icon(Icons.star),
              label: const Text('Load Characters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(HeroSearchProvider provider, BuildContext context) {
    // Show error message if any
    if (provider.error != null) {
      return _buildErrorWidget(provider);
    }

    // Show loading indicator
    if (provider.isLoading) {
      return _buildLoadingWidget();
    }

    // Show search results
    if (provider.searchResults.isNotEmpty) {
      return _buildSearchResults(provider, context);
    }

    // Show empty state
    return _buildEmptyState();
  }

  Widget _buildErrorWidget(HeroSearchProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                provider.error ?? 'An error occurred',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: provider.clearError,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading...'),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    HeroSearchProvider provider,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Results (${provider.searchResults.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              final hero = provider.searchResults[index];
              return _HeroCard(
                hero: hero,
                onTap: () => _navigateToHeroDetail(context, hero),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Search for superheroes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a hero name to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final HeroModel hero;
  final VoidCallback onTap;

  const _HeroCard({
    required this.hero,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildHeroImage(),
            ),
            _buildHeroName(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: Image.network(
        hero.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey.withOpacity(0.5),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroName(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        hero.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
