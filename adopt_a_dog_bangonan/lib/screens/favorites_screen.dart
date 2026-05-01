import 'package:adopt_a_dog/models/favorite.dart';
import 'package:adopt_a_dog/screens/settings_screen.dart';
import 'package:adopt_a_dog/services/dog_api_service.dart';
import 'package:adopt_a_dog/services/prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Favorite>> _favoritesFuture;
  final _prefs = PrefsService();

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _prefs.loadFavorites();
  }

  Future<void> _removeFavorite(Favorite favorite) async {
    await _prefs.removeFavorite(favorite);
    setState(() {
      _favoritesFuture = _prefs.loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: FutureBuilder<List<Favorite>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final favorites = snapshot.data!;
          if (favorites.isEmpty) {
            return const Center(
              child: Text(
                'No favorites saved yet!\nTap ♥ on any breed photo.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () {
                    // Navigate to favorite detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _FavoriteDetailScreen(
                          breedName: favorite.breedName,
                          imageUrl: favorite.imageUrl,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Breed image (using the saved image URL)
                        CachedNetworkImage(
                          imageUrl: favorite.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const SizedBox(
                            width: 80,
                            height: 80,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 40),
                        ),
                        const SizedBox(width: 16),
                        // Breed info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                favorite.breedName[0].toUpperCase() + favorite.breedName.substring(1),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Saved image - click to view details',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Actions
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeFavorite(favorite),
                              tooltip: 'Remove from favorites',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoriteDetailScreen extends StatefulWidget {
  final String breedName;
  final String imageUrl;
  const _FavoriteDetailScreen({required this.breedName, required this.imageUrl});

  @override
  State<_FavoriteDetailScreen> createState() => _FavoriteDetailScreenState();
}

class _FavoriteDetailScreenState extends State<_FavoriteDetailScreen> {
  late Future<String> _imageFuture;
  final _api = DogApiService();
  final _prefs = PrefsService();
  bool _saved = true;

  @override
  void initState() {
    super.initState();
    _imageFuture = _api.fetchRandomImage(widget.breedName);
  }

  void _refresh() => setState(() {
    _imageFuture = _api.fetchRandomImage(widget.breedName);
  });

  Future<void> _removeFavorite() async {
    // Create a Favorite object to remove
    final favorite = Favorite(
      breedName: widget.breedName,
      imageUrl: widget.imageUrl,
    );
    await _prefs.removeFavorite(favorite);
    setState(() => _saved = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.breedName} removed from favorites!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.breedName)),
      body: FutureBuilder<String>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final url = snapshot.data!;
          return Column(
            children: [
              // Make image scrollable to see full picture
              Expanded(
                child: SingleChildScrollView(
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.6,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, size: 64),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('New Photo', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _saved ? _removeFavorite : null,
                      icon: Icon(
                        _saved ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                      ),
                      label: const Text('Remove Favorite', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
