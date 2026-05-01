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
  late Future<List<String>> _favoritesFuture;
  final _prefs = PrefsService();
  final _api = DogApiService();

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _prefs.loadFavorites();
  }

  Future<void> _removeFavorite(String breedName) async {
    await _prefs.removeFavorite(breedName);
    setState(() {
      _favoritesFuture = _prefs.loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: FutureBuilder<List<String>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final favorites = snapshot.data!;
          
          if (favorites.isEmpty) {
            return const Center(
              child: Text(
                'No favorites saved yet!\n'
                'Tap ♥ on any breed photo.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final breed = favorites[index];
              return FutureBuilder<String>(
                future: _api.fetchRandomImage(breed),
                builder: (context, imgSnap) {
                  if (imgSnap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (imgSnap.hasError) {
                    return ListTile(
                      title: Text(breed),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeFavorite(breed),
                      ),
                    );
                  }

                  return ListTile(
                    leading: imgSnap.data != null
                        ? CachedNetworkImage(
                            imageUrl: imgSnap.data!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Icon(Icons.pets),
                            errorWidget: (context, url, error) => const Icon(Icons.pets),
                          )
                        : const Icon(Icons.pets),
                    title: Text(breed),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeFavorite(breed),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
