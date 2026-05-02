import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../services/superhero_api_service.dart';
import '../../router/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  late final Future<List<HeroModel>> _heroFuture;
  String _selectedPublisher = 'All';

  // Publisher options for filtering
  final List<String> _publishers = [
    'All',
    'Marvel',
    'DC',
    'Dark Horse',
    'Image',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize HeroSearchProvider with all heroes for local filtering
    _initializeSearchProvider();
    // Store Future once — never create it inside build()
    _heroFuture = SuperheroApiService().fetchRandomHeroes(count: 20);
  }

  Future<void> _initializeSearchProvider() async {
    // Initialize the search provider and load last search query
    await context.read<HeroSearchProvider>().initialize();

    // Guard against async context usage
    if (!mounted) return;

    // Launch Restoration: Load last search query and pre-fill search bar
    final searchProvider = context.read<HeroSearchProvider>();
    final lastQuery = await searchProvider.loadLastSearch();
    if (lastQuery != null && lastQuery.isNotEmpty) {
      _searchController.text = lastQuery;
      setState(() {
        _isSearching = true;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) {
      _clearSearch();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Search on Submit: Filter heroes and save to SharedPreferences
    context.read<HeroSearchProvider>().searchHeroes(query.trim());
    context.read<HeroSearchProvider>().saveSearchQuery(query.trim());
  }

  void _onSearchChanged(String query) {
    // Fix Backspace Logic: Simply filter without triggering navigation or state changes
    context.read<HeroSearchProvider>().searchHeroes(query);

    // Only update UI state if needed
    if (query.trim().isNotEmpty && !_isSearching) {
      setState(() {
        _isSearching = true;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    context.read<HeroSearchProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom Header with Background Image
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            primary: true, // Proper status bar integration
            stretch: true,
            actions: [
              // Battle History button
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: () =>
                    Navigator.pushNamed(context, RouteNames.history),
                tooltip: 'Battle History',
              ),
              // Profile button
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () =>
                    Navigator.pushNamed(context, RouteNames.profile),
                tooltip: 'Profile',
              ),
              // Deck badge
              Consumer<DeckProvider>(
                builder: (context, deck, _) => Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.style, color: Colors.white),
                      onPressed: () =>
                          Navigator.pushNamed(context, RouteNames.deckBuilder),
                    ),
                    if (deck.deckSize > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            '${deck.deckSize}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero-themed background image
                  Image.network(
                    'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=400&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF7B2FBE), Color(0xFF2E0854)],
                          ),
                        ),
                      );
                    },
                  ),
                  // Dark gradient overlay for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Content overlay with tight padding
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                      top: 40.0, // Account for status bar and toolbar
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Center the content
                      children: [
                        const Spacer(),
                        // Centered Modern Typography Title
                        Text(
                          'HERO ROSTER',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 3,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Integrated Search Bar with Glassmorphism
                        _buildGlassmorphismSearchBar(),
                        const SizedBox(height: 16),
                        // Horizontal Category Chips
                        _buildCategoryChips(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Hero Grid Content
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: _buildHeroContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroContent() {
    return Consumer<HeroSearchProvider>(
      builder: (context, searchProvider, child) {
        if (!searchProvider.isSearching) {
          return _buildRandomHeroesGrid();
        }
        return _buildSearchResultsGrid();
      },
    );
  }

  Widget _buildGlassmorphismSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search heroes...',
              hintStyle: const TextStyle(color: Colors.white70),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
            style: const TextStyle(color: Colors.white),
            onSubmitted: _onSearchSubmitted,
            onChanged: _onSearchChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _publishers.length,
        itemBuilder: (context, index) {
          final publisher = _publishers[index];
          final isSelected = publisher == _selectedPublisher;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(publisher),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPublisher = publisher;
                });
                _filterByPublisher(publisher);
              },
              backgroundColor: Colors.white.withOpacity(0.2),
              selectedColor: Colors.white.withOpacity(0.4),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRandomHeroesGrid() {
    return FutureBuilder<List<HeroModel>>(
      future: _heroFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load heroes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _heroFuture = SuperheroApiService().fetchRandomHeroes(
                            count: 20,
                          );
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final heroes = _filterHeroesByPublisher(snapshot.data!);
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildModernHeroCard(heroes[index]),
            childCount: heroes.length,
          ),
        );
      },
    );
  }

  Widget _buildSearchResultsGrid() {
    return Consumer<HeroSearchProvider>(
      builder: (context, searchProvider, child) {
        if (searchProvider.searchResults.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No heroes found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final heroes = _filterHeroesByPublisher(searchProvider.searchResults);
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildModernHeroCard(heroes[index]),
            childCount: heroes.length,
          ),
        );
      },
    );
  }

  Widget _buildModernHeroCard(HeroModel hero) {
    return Consumer<DeckProvider>(
      builder: (context, deckProvider, _) {
        final bool isInDeck = deckProvider.deck.any((h) => h.id == hero.id);
        final bool isDeckFull = deckProvider.deckSize >= 5;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                // Hero Image
                CachedNetworkImage(
                  imageUrl: hero.displayImageUrl.isNotEmpty
                      ? hero.displayImageUrl
                      : 'https://via.placeholder.com/300x400.png?text=No+Image',
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 50),
                  ),
                ),
                // Semi-transparent black bar at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hero.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            hero.publisher,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Floating Add to Deck Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      _handleAddToDeck(
                        hero,
                        deckProvider,
                        isInDeck,
                        isDeckFull,
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Icon(
                              isInDeck ? Icons.check_circle : Icons.add,
                              color: isInDeck
                                  ? Colors.green.shade300
                                  : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Tap gesture for hero details
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RouteNames.heroDetail,
                          arguments: hero,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleAddToDeck(
    HeroModel hero,
    DeckProvider deckProvider,
    bool isInDeck,
    bool isDeckFull,
  ) {
    if (isInDeck) {
      // Hero already in deck - show message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hero already in deck!'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (isDeckFull) {
      // Deck is full - show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deck is full! Max 5 heroes allowed'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Add hero to deck
    deckProvider.addHero(hero);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${hero.name} added to your deck!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<HeroModel> _filterHeroesByPublisher(List<HeroModel> heroes) {
    if (_selectedPublisher == 'All') {
      return heroes;
    }
    return heroes
        .where(
          (hero) => hero.publisher.toLowerCase().contains(
            _selectedPublisher.toLowerCase(),
          ),
        )
        .toList();
  }

  void _filterByPublisher(String publisher) {
    // This will trigger a rebuild with the filtered results
    setState(() {});
  }
}
