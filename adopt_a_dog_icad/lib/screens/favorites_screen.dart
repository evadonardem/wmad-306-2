import 'package:flutter/material.dart';
import '../models/breed.dart';
import '../services/prefs_service.dart';
import 'breed_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PrefsService _prefs = PrefsService();
  final _searchController = TextEditingController();
  late Future<List<String>> _favoritesFuture;
  List<String> _allFavorites = [];
  List<String> _filteredFavorites = [];

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _prefs.loadFavorites();
  }

  void _filterFavorites(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFavorites = List.from(_allFavorites);
      } else {
        _filteredFavorites = _allFavorites
            .where((favorite) =>
                favorite.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _removeFavorite(String breedName) async {
    await _prefs.removeFavorite(breedName);
    setState(() {
      _favoritesFuture = _prefs.loadFavorites();
      _filteredFavorites.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$breedName removed from favorites'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green[400],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background for aesthetics
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E8), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar replacement with custom design
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'My Favorites',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search favorites...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _filterFavorites,
                ),
              ),
              // Favorites list
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _favoritesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    _allFavorites = snapshot.data ?? [];

                    if (_filteredFavorites.isEmpty &&
                        _searchController.text.isEmpty) {
                      _filteredFavorites = List.from(_allFavorites);
                    }

                    if (_allFavorites.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite_border,
                                size: 80, color: Colors.green),
                            const SizedBox(height: 20),
                            const Text(
                              'No favorites yet!',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap the heart icon on any breed photo to save it here.',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final favorite = _filteredFavorites[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: const Icon(Icons.pets, color: Colors.green),
                            ),
                            title: Text(
                              favorite,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeFavorite(favorite),
                            ),
                            onTap: () {
                              // Navigate to breed detail screen
                              final breed = Breed(
                                name: favorite.split(' ').last,
                                subBreeds: [],
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BreedDetailScreen(breed: breed),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}