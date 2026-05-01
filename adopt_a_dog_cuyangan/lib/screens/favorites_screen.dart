import 'package:flutter/material.dart';
import '../models/breed.dart';
import '../services/dog_api_service.dart';
import '../services/prefs_service.dart';
import 'breed_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PrefsService _prefs = PrefsService();
  final DogApiService _api = DogApiService();
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
        _filteredFavorites = _allFavorites.where((favorite) =>
          favorite.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  Future<void> _removeFavorite(String breedName) async {
    await _prefs.removeFavorite(breedName);
    setState(() {
      _favoritesFuture = _prefs.loadFavorites();
      // Also clear the filtered list to force refresh
      _filteredFavorites.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$breedName removed from favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Very light gray background
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'My Favorites',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        titleSpacing: 0, // Remove default spacing to control it manually
        leadingWidth: 56, // Ensure consistent leading width
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search favorites...',
                hintStyle: TextStyle(color: Color(0xFF757575)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF4CAF50)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                _allFavorites = snapshot.data!;
                
                // Initialize filtered list if empty
                if (_filteredFavorites.isEmpty && _searchController.text.isEmpty) {
                  _filteredFavorites = List.from(_allFavorites);
                }
                
                if (_allFavorites.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E8), // Very light green
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            size: 48,
                            color: Color(0xFF4CAF50), // Light green
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No favorites saved yet!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap ♥ on any breed photo.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (_filteredFavorites.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No favorites found matching your search.',
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredFavorites.length,
                  itemBuilder: (context, index) {
                    final favorite = _filteredFavorites[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E8), // Very light green
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Color(0xFFE53935), // Red heart for contrast
                              size: 24,
                            ),
                          ),
                          title: Text(
                            favorite,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Tap to view photos',
                            style: TextStyle(
                              color: const Color(0xFF757575),
                              fontSize: 14,
                            ),
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE), // Very light red
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFFE53935), // Red delete icon
                              ),
                              onPressed: () => _removeFavorite(favorite),
                              style: IconButton.styleFrom(
                                foregroundColor: const Color(0xFFE53935),
                              ),
                            ),
                          ),
                          onTap: () {
                            // Navigate to breed detail if it's a valid breed name
                            final breedName = favorite.split(' ').last.toLowerCase();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BreedDetailScreen(
                                  breed: Breed(name: breedName, subBreeds: []),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
