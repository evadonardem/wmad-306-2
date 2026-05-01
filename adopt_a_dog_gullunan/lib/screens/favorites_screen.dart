import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/screens/breed_detail_screen.dart';
import 'package:adopt_a_dog/screens/breed_list_screen.dart';
import 'package:adopt_a_dog/services/dog_api_service.dart';
import 'package:adopt_a_dog/services/prefs_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PrefsService _prefsService = PrefsService();
  final DogApiService _apiService = DogApiService();
  late Future<List<Breed>> _allBreedsFuture;
  final Map<String, String> _breedDescriptions = {
    'labrador': 'Friendly, outgoing, and active companions who have more than enough affection to go around for a family looking for a medium-to-large dog.',
    'german': 'German Shepherds are large, athletic dogs with a noble character and high intelligence. They are extremely loyal and versatile.',
    'golden': 'Golden Retrievers are friendly, intelligent, and devoted companions. They are patient with children and make excellent family dogs.',
    'bulldog': 'Bulldogs are calm, courageous, and friendly. They are known for their loose-jointed, shuffling gait and massive, short-faced head.',
    'beagle': 'Beagles are curious, friendly, and merry dogs. They make excellent hunting companions and great family pets.',
    'poodle': 'Poodles are exceptional dogs renowned for their intelligence, trainability, and hypoallergenic coats.',
    'rottweiler': 'Rottweilers are powerful, loyal, and confident dogs. They are protective of their families and make excellent guard dogs.',
    'y Chihuahua': 'Chihuahuas are tiny dogs with big personalities. They are alert, swift-moving, and fiercely loyal to their owners.',
    'husky': 'Siberian Huskies are energetic, intelligent, and outgoing dogs. They are known for their striking blue eyes and thick coats.',
    'dachshund': 'Dachshunds are clever, lively, and courageous dogs with a unique elongated body. They are spunky and curious.',
  };

  String _getBreedDescription(String breedName) {
    final lowerCaseName = breedName.toLowerCase();
    
    // Check for exact matches first
    if (_breedDescriptions.containsKey(lowerCaseName)) {
      return _breedDescriptions[lowerCaseName]!;
    }
    
    // Check for partial matches
    for (final key in _breedDescriptions.keys) {
      if (lowerCaseName.contains(key) || key.contains(lowerCaseName)) {
        return _breedDescriptions[key]!;
      }
    }
    
    // Default description
    return 'A wonderful dog breed with unique characteristics and qualities that make them special companions.';
  }

  @override
  void initState() {
    super.initState();
    _allBreedsFuture = _apiService.fetchBreeds();
  }

  Future<void> _clearAllFavorites() async {
    await _prefsService.clearAllFavorites();
    setState(() {});
  }

  Future<void> _removeFavorite(String breedName) async {
    await _prefsService.removeFavorite(breedName);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade50,
              Colors.white,
              Colors.red.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Professional Header
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.shade200,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Favorites',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                ),
                              ),
                              Text(
                                'Your beloved furry companions',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const BreedListScreen()),
                              (route) => false,
                            ),
                            icon: Icon(
                              Icons.home,
                              color: Colors.red.shade400,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Favorites List
              Expanded(
                child: FutureBuilder<List<Breed>>(
                  future: _allBreedsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading your favorites...',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Oops! Something went wrong',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return FutureBuilder<List<String>>(
                      future: _prefsService.loadFavorites(),
                      builder: (context, favSnapshot) {
                        if (favSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          );
                        }
                        if (!favSnapshot.hasData || favSnapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No favorite breeds yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start adding your favorite dogs!',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final allBreeds = snapshot.data ?? [];
                        final favoriteNames = favSnapshot.data!;
                        final favorites = favoriteNames
                            .map((name) => allBreeds.firstWhere(
                                  (breed) => breed.name == name,
                                  orElse: () => Breed(name: name, subBreeds: []),
                                ))
                            .toList();

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final breed = favorites[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                      // Dog Image with fixed aspect ratio
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: FutureBuilder<String>(
                                        future: _apiService.fetchRandomImage(breed: breed.name),
                                        builder: (context, imageSnapshot) {
                                          if (imageSnapshot.connectionState == ConnectionState.waiting) {
                                            return Container(
                                              color: Colors.grey.shade200,
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                                ),
                                              ),
                                            );
                                          }
                                          if (imageSnapshot.hasError) {
                                            return Container(
                                              color: Colors.grey.shade300,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.error,
                                                  color: Colors.grey,
                                                  size: 48,
                                                ),
                                              ),
                                            );
                                          }
                                          return CachedNetworkImage(
                                            imageUrl: imageSnapshot.data!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey.shade200,
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: Colors.grey.shade300,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.error,
                                                  color: Colors.grey,
                                                  size: 48,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Breed Info
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                breed.name,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red.shade800,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red.shade600,
                                                ),
                                                onPressed: () => _removeFavorite(breed.name),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          breed.subBreeds.isEmpty
                                              ? 'Single breed'
                                              : '${breed.subBreeds.length} sub-breed${breed.subBreeds.length > 1 ? 's' : ''} available',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _getBreedDescription(breed.name),
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => BreedDetailScreen(breed: breed),
                                              ),
                                            ),
                                            icon: const Icon(Icons.visibility),
                                            label: const Text('View Details'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red.shade400,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
      floatingActionButton: FloatingActionButton(
        onPressed: _clearAllFavorites,
        backgroundColor: Colors.red.shade400,
        child: const Icon(Icons.delete_sweep, color: Colors.white),
      ),
    );
  }
}
