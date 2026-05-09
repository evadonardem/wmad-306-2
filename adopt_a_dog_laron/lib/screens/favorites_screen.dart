import 'package:adopt_a_dog/services/dog_api_service.dart';
import 'package:adopt_a_dog/services/prefs_service.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _prefs = PrefsService();
  final _api = DogApiService();
  String? _favorite;
  String? _imageUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final favorite = await _prefs.loadFavorite();
    if (favorite != null) {
      // Parse breed and sub-breed from display name
      final parts = favorite.split(' ');
      String breed;
      String? subBreed;
      if (parts.length > 1) {
        subBreed = parts.first;
        breed = parts.skip(1).join(' ');
      } else {
        breed = favorite;
      }
      try {
        final imageUrl = await _api.fetchRandomImage(breed, subBreed: subBreed);
        setState(() {
          _favorite = favorite;
          _imageUrl = imageUrl;
          _loading = false;
        });
      } catch (e) {
        setState(() {
          _favorite = favorite;
          _loading = false;
        });
      }
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _clearFavorite() async {
    await _prefs.clearFavorite();
    setState(() {
      _favorite = null;
      _imageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorite')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorite == null
              ? const Center(
                  child: Text(
                    'No favorite breed selected yet.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _favorite!,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      if (_imageUrl != null)
                        Center(
                          child: Image.network(_imageUrl!, height: 200),
                        ),
                    ],
                  ),
                ),
      floatingActionButton: _favorite != null
          ? FloatingActionButton(
              onPressed: _clearFavorite,
              child: const Icon(Icons.delete),
            )
          : null,
    );
  }
}
