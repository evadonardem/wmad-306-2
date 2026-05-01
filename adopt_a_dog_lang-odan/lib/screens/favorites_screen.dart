import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../services/dog_api_service.dart';
import '../models/breed.dart';
import 'breed_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PrefsService _prefs = PrefsService();
  final DogApiService _api = DogApiService();
  List<String> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favorites = await _prefs.loadFavorites();
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(String breedName) async {
    await _prefs.removeFavorite(breedName);
    await _loadFavorites();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$breedName removed from favorites')),
      );
    }
  }

  Future<void> _clearAllFavorites() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text('Are you sure you want to remove all favorite breeds?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await _prefs.clearAllFavorites();
      await _loadFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All favorites cleared')),
        );
      }
    }
  }

  // ✅ _openFullScreen is now INSIDE the class
  void _openFullScreen(BuildContext context, String imageUrl, String breedName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              breedName,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (ctx, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (ctx, url, err) => const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              onPressed: _clearAllFavorites,
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _favorites.isNotEmpty
          ? FloatingActionButton(
              onPressed: _clearAllFavorites,
              child: const Icon(Icons.delete),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No favorite breeds yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Save your favorite breeds from the detail screen',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final breedName = _favorites[index];
        final displayName = breedName.contains('/')
            ? breedName.split('/').last
            : breedName;
        final parentBreed = breedName.contains('/')
            ? breedName.split('/').first
            : null;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            // ✅ GestureDetector is now INSIDE FutureBuilder
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: FutureBuilder<String>(
                future: _api.fetchRandomImage(breedName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    return GestureDetector(
                      onTap: () => _openFullScreen(
                        context,
                        snapshot.data!,
                        breedName,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: snapshot.data!,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (ctx, url, err) =>
                              const Icon(Icons.pets),
                        ),
                      ),
                    );
                  }
                  return const Icon(Icons.pets);
                },
              ),
            ),
            title: Text(
              displayName.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: parentBreed != null
                ? Text(
                    parentBreed,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  )
                : null,
            trailing: IconButton(
              onPressed: () => _removeFavorite(breedName),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Remove from favorites',
            ),
            onTap: () {
              final parts = breedName.split('/');
              final breed = parts.length == 2
                  ? Breed(name: parts[0], subBreeds: [parts[1]])
                  : Breed(name: breedName, subBreeds: []);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BreedDetailScreen(breed: breed),
                ),
              );
            },
          ),
        );
      },
    );
  }
}