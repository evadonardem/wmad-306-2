import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/services/dog_api_service.dart';
import 'package:adopt_a_dog/services/prefs_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BreedDetailScreen extends StatefulWidget {
  final Breed breed;
  const BreedDetailScreen({super.key, required this.breed});
  @override
  State<BreedDetailScreen> createState() => _BreedDetailScreenState();
}

class _BreedDetailScreenState extends State<BreedDetailScreen> with SingleTickerProviderStateMixin {
  final DogApiService _apiService = DogApiService();
  final PrefsService _prefsService = PrefsService();

  late final AnimationController _loadingAnimationController;

  String? _selectedSubBreed;
  late Future<String> _imageFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _selectedSubBreed = null;
    _imageFuture = _loadImage();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final current = _currentPath;
    final isFav = await _prefsService.isFavorite(current);
    setState(() {
      _isFavorite = isFav;
    });
  }

  String get _currentPath {
    if (_selectedSubBreed == null) {
      return widget.breed.name;
    }
    return '${widget.breed.name}/$_selectedSubBreed';
  }

  Future<String> _loadImage() {
    return _apiService.fetchRandomImage(
      breed: widget.breed.name,
      subBreed: _selectedSubBreed,
    );
  }

  void _selectSubBreed(String? subBreed) {
    setState(() {
      _selectedSubBreed = subBreed;
      _imageFuture = _loadImage();
    });
    _checkFavoriteStatus();
  }

  Future<void> _toggleFavorite() async {
    final current = _currentPath;
    var message = '';
    if (_isFavorite) {
      await _prefsService.removeFavorite(current);
      message = 'Removed from favorites';
    } else {
      await _prefsService.addFavorite(current);
      message = 'Added to favorites';
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subBreeds = widget.breed.subBreeds;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: 'breed-hero-${widget.breed.name}',
              child: const Icon(Icons.pets, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Flexible(child: Text(widget.breed.displayName(sub: _selectedSubBreed))),
          ],
        ),
        backgroundColor: Colors.green.shade800,
        elevation: 4,
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: IconButton(
              key: ValueKey<bool>(_isFavorite),
              icon: Icon(_isFavorite ? Icons.pets : Icons.pets_outlined),
              onPressed: _toggleFavorite,
              color: _isFavorite ? Colors.orangeAccent : Colors.white,
              tooltip: _isFavorite ? 'Unfavorite' : 'Favorite',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9F7EF), Color(0xFF8EE4AF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            if (subBreeds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: subBreeds.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ChoiceChip(
                          label: const Text('All'),
                          selected: _selectedSubBreed == null,
                          onSelected: (_) => _selectSubBreed(null),
                        );
                      }

                      final subBreed = subBreeds[index - 1];
                      return ChoiceChip(
                        label: Text(subBreed),
                        selected: _selectedSubBreed == subBreed,
                        onSelected: (_) => _selectSubBreed(subBreed),
                      );
                    },
                  ),
                ),
              ),
            Expanded(
              child: FutureBuilder<String>(
                future: _imageFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotationTransition(
                            turns: _loadingAnimationController,
                            child: const Icon(
                              Icons.pets,
                              size: 72,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Loading paw print',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading image: ${snapshot.error}'),
                    );
                  }

                  final imageUrl = snapshot.data;
                  if (imageUrl == null) {
                    return const Center(child: Text('No image available'));
                  }

                  return Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: Hero(
                        tag: 'breed-image-${widget.breed.name}-${_selectedSubBreed ?? 'all'}',
                        child: CachedNetworkImage(
                          key: ValueKey<String>(imageUrl),
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, size: 48)),
                          memCacheWidth: 1024,
                          memCacheHeight: 1024,
                          cacheKey: imageUrl,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reload image'),
              onPressed: () {
                setState(() {
                  _imageFuture = _loadImage();
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
