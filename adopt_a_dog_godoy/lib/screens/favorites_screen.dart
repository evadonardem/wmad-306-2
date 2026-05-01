import 'package:adopt_a_dog/services/prefs_service.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _prefsService = PrefsService();
  late Future<List<String>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _prefsService.loadFavorites();
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _favoritesFuture = _prefsService.loadFavorites();
    });
  }

  Future<void> _removeFavorite(String breed) async {
    await _prefsService.removeFavorite(breed);
    await _refreshFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorite')),
      body: FutureBuilder<List<String>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load favorites.'));
          }

          final favorites = snapshot.data ?? <String>[];
          if (favorites.isEmpty) {
            return const Center(child: Text('No favorites saved.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final breed = favorites[index];
              return ListTile(
                title: Text(breed),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeFavorite(breed),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
