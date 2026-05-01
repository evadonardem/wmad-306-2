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

class _BreedDetailScreenState extends State<BreedDetailScreen> {
  late Future<String> _imageFuture;
  late DogApiService _apiService;
  late PrefsService _prefsService;
  String? _selectedSubBreed;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _apiService = DogApiService();
    _prefsService = PrefsService();
    _imageFuture = _apiService.fetchRandomImage(breed: widget.breed.name);
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final favorites = await _prefsService.loadFavorites();
    setState(() {
      _isFavorite = favorites.contains(widget.breed.name);
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _prefsService.removeFavorite(widget.breed.name);
    } else {
      await _prefsService.addFavorite(widget.breed.name);
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _updateImage(String? subBreed) {
    setState(() {
      _selectedSubBreed = subBreed;
      _imageFuture = _apiService.fetchRandomImage(
        breed: widget.breed.name,
        subBreed: subBreed,
      );
    });
  }

  Future<String> _fetchRandomImage() async {
    return _apiService.fetchRandomImage(
      breed: widget.breed.name,
      subBreed: _selectedSubBreed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.breed.name),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.breed.subBreeds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: _selectedSubBreed == null,
                        onSelected: (_) => _updateImage(null),
                      ),
                    ),
                    ...widget.breed.subBreeds.map(
                      (subBreed) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FilterChip(
                          label: Text(subBreed),
                          selected: _selectedSubBreed == subBreed,
                          onSelected: (_) => _updateImage(subBreed),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return FutureBuilder<String>(
                    future: _imageFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      return InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 3.0,
                        child: CachedNetworkImage(
                          imageUrl: snapshot.data!,
                          fit: BoxFit.contain,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _imageFuture = _fetchRandomImage();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Photo'),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: const Text('Favorite'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
