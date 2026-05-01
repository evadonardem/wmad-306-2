import 'dart:async';
import 'dart:math';

import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/screens/breed_detail_screen.dart';
import 'package:adopt_a_dog/screens/categories_screen.dart';
import 'package:adopt_a_dog/screens/favorites_screen.dart';
import 'package:adopt_a_dog/services/dog_api_service.dart';
import 'package:flutter/material.dart';

class BreedListScreen extends StatefulWidget {
  const BreedListScreen({super.key});

  @override
  State<BreedListScreen> createState() => _BreedListScreenState();
}

class _BreedListScreenState extends State<BreedListScreen> {
  final DogApiService _apiService = DogApiService();

  late final Future<List<Breed>> _breedsFuture;
  int _hoveringPromoIndex = -1;
  List<String> _carouselImages = [];
  List<String> _carouselBreedNames = [];
  int _carouselIndex = 0;
  bool _isCarouselLoading = true;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _breedsFuture = _apiService.fetchBreeds();
    _loadCarouselImages();
  }

  void _startCarouselAutoRotate() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_carouselImages.isEmpty) return;
      setState(() {
        _carouselIndex = (_carouselIndex + 1) % _carouselImages.length;
      });
    });
  }

  Future<void> _loadCarouselImages() async {
    setState(() {
      _isCarouselLoading = true;
    });

    try {
      final breeds = await _breedsFuture;
      if (breeds.isEmpty) {
        setState(() {
          _carouselImages = [];
          _carouselIndex = 0;
        });
        return;
      }

      final random = Random();
      final breedCandidates = List.of(breeds);
      breedCandidates.shuffle(random);
      final selected = breedCandidates.take(min(5, breedCandidates.length)).toList();

      final images = <String>[];
      final names = <String>[];
      for (final breed in selected) {
        final subBreed = breed.subBreeds.isNotEmpty
            ? breed.subBreeds[random.nextInt(breed.subBreeds.length)]
            : null;
        final imageUrl = await _apiService.fetchRandomImage(breed: breed.name, subBreed: subBreed);
        images.add(imageUrl);
        if (subBreed != null && subBreed.isNotEmpty) {
          names.add('${breed.name} $subBreed');
        } else {
          names.add(breed.name);
        }
      }

      setState(() {
        _carouselImages = images;
        _carouselBreedNames = names;
        _carouselIndex = 0;
      });

      _startCarouselAutoRotate();
    } catch (_) {
      setState(() {
        _carouselImages = [];
      });
    } finally {
      setState(() {
        _isCarouselLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3E5FC),
      body: Column(
        children: [
          Container(
            height: 110,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C61B3), Color(0xFF4285F4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Furever',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.pets, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPromoCard('Categories', Colors.white, () async {
                  final breeds = await _breedsFuture;
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CategoriesScreen(breeds: breeds)),
                  );
                  await _loadCarouselImages();
                }, 0),
                _buildPromoCard('Surprise me!', Colors.white, () async {
                  final breeds = await _breedsFuture;
                  if (breeds.isNotEmpty) {
                    final randomBreed = breeds[Random().nextInt(breeds.length)];
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BreedDetailScreen(breed: randomBreed)),
                    );
                    await _loadCarouselImages();
                  }
                }, 1),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildCarouselSection(),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB6E3C2), Color(0xFFB4E8FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 20,
                  child: Opacity(
                    opacity: 0.08,
                    child: Icon(Icons.pets, size: 140, color: Colors.white),
                  ),
                ),
                Positioned(
                  bottom: 80,
                  right: 30,
                  child: Opacity(
                    opacity: 0.08,
                    child: Icon(Icons.pets, size: 120, color: Colors.white),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.list_alt, size: 64, color: Colors.white70),
                        SizedBox(height: 16),
                        Text(
                          'Browse breeds from Categories',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Use the categories button to open the breed list.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(String title, Color color, VoidCallback onTap, int index) {
    final hoverScale = _hoveringPromoIndex == index ? 1.05 : 1.0;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveringPromoIndex = index),
        onExit: (_) => setState(() => _hoveringPromoIndex = -1),
        child: AnimatedScale(
          scale: hoverScale,
          duration: const Duration(milliseconds: 170),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade100),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselSection() {
    if (_isCarouselLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_carouselImages.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: TextButton(
            onPressed: _loadCarouselImages,
            child: const Text('Load dog carousel'),
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: _carouselImages.length,
              onPageChanged: (index) => setState(() => _carouselIndex = index),
              itemBuilder: (context, index) {
                final imageUrl = _carouselImages[index];
                final breedName = _carouselBreedNames.length > index ? _carouselBreedNames[index] : 'Dog';
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Hero(
                    tag: 'carousel-hero-$index',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black26, Colors.black12],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  breedName.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    shadows: [
                                      Shadow(color: Colors.black45, blurRadius: 10),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Adopt a Best Friend, Best Friends Furever!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(color: Colors.black38, blurRadius: 8),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
