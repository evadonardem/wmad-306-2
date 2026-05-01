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

  Future<void> _reloadFavorites() async {
    setState(() {
      _favoritesFuture = _prefsService.loadFavorites();
    });
  }

  Future<void> _deleteFavorite(String breed) async {
    await _prefsService.removeFavorite(breed);
    await _reloadFavorites();
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

          final favorites = snapshot.data ?? <String>[];
          if (favorites.isEmpty) {
            return const Center(
              child: Text('No favorites saved yet.'),
            );
          }

          return ListView.separated(
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final breed = favorites[index];
              return ListTile(
                title: Text(breed),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteFavorite(breed),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
