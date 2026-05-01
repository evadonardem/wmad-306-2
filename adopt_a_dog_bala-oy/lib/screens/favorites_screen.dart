import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/screens/breed_detail_screen.dart';
import 'package:adopt_a_dog/services/prefs_service.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<String>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    _favoritesFuture = PrefsService().loadFavorites();
  }

  Future<void> _removeFavorite(String breedName) async {
    await PrefsService().removeFavorite(breedName);
    if (mounted) {
      setState(() {
        _loadFavorites();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$breedName removed from favorites')),
      );
    }
  }

  Future<void> _clearAllFavorites() async {
    await PrefsService().clearFavorites();
    if (mounted) {
      setState(() {
        _loadFavorites();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All favorites cleared')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: FutureBuilder<List<String>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No favorites yet. Add some breeds to your favorites!',
                textAlign: TextAlign.center,
              ),
            );
          } else {
            final favoriteNames = snapshot.data!;
            return ListView.builder(
              itemCount: favoriteNames.length,
              itemBuilder: (context, index) {
                final breedName = favoriteNames[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      breedName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFavorite(breedName),
                    ),
                    onTap: () async {
                      // For simplicity, create a breed object with name only
                      // In a real app, you might store full breed data
                      final breed = Breed(name: breedName, subBreeds: []);
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearAllFavorites,
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete_forever),
      ),
    );
  }
}
