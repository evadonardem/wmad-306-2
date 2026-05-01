import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../services/dog_api_service.dart';
import 'breed_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _prefs = PrefsService();
  final _api = DogApiService();
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    _favorites = await _prefs.loadFavorites();
    setState(() {});
  }

  void _openDetail(String name) async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    final breed = await _api.findBreedByName(name);
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => BreedDetailScreen(breed: breed)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: _favorites.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final name = _favorites[index];
                return ListTile(
                  title: Text(name[0].toUpperCase() + name.substring(1)),
                  onTap: () => _openDetail(name), // Made functional
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _favorites.removeAt(index);
                      _prefs.saveFavorites(_favorites);
                      setState(() {});
                    },
                  ),
                );
              },
            ),
    );
  }
}