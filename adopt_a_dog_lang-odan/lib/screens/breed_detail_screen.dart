import 'package:flutter/material.dart';
import '../models/breed.dart';
import '../services/dog_api_service.dart';
import '../services/prefs_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BreedDetailScreen extends StatefulWidget {
  final Breed breed;
  const BreedDetailScreen({super.key, required this.breed});

  @override
  State<BreedDetailScreen> createState() => _BreedDetailScreenState();
}

class _BreedDetailScreenState extends State<BreedDetailScreen> {
  late Future<String> _imageFuture;
  final _api = DogApiService();
  final _prefs = PrefsService();
  bool _saved = false;
  String? _selectedSubBreed;

  @override
  void initState() {
    super.initState();
    _loadInitialImage();
  }

  void _loadInitialImage() {
    _imageFuture = _api.fetchRandomImage(widget.breed.name);
  }

  void _refresh() => setState(() {
        if (_selectedSubBreed != null) {
          _imageFuture = _api.fetchRandomImage(
            '${widget.breed.name}/${_selectedSubBreed!}',
          );
        } else {
          _imageFuture = _api.fetchRandomImage(widget.breed.name);
        }
        _saved = false;
      });

  void _onSubBreedTap(String subBreed) {
    setState(() {
      _selectedSubBreed = subBreed;
      _imageFuture = _api.fetchRandomImage(
        '${widget.breed.name}/$subBreed',
      );
      _saved = false;
    });
  }

  Future<void> _saveFavorite() async {
    String favoriteKey = _selectedSubBreed != null
        ? '${widget.breed.name}/${_selectedSubBreed!}'
        : widget.breed.name;
    await _prefs.saveFavorite(favoriteKey);
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$favoriteKey saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.breed.name)),
      body: FutureBuilder<String>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final url = snapshot.data!;
          return Column(
            children: [
              // Chip row for sub-breeds (only if breed has sub-breeds)
              if (widget.breed.subBreeds.isNotEmpty)
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.breed.subBreeds.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final subBreed = widget.breed.subBreeds[index];
                      final isSelected = _selectedSubBreed == subBreed;
                      return FilterChip(
                        label: Text(subBreed),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            _onSubBreedTap(subBreed);
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    },
                  ),
                ),
            Expanded(
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (ctx, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (ctx, url, err) =>
                          const Icon(Icons.broken_image, size: 64),
                    ),
                  ),
                
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('New Photo'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _saved ? null : _saveFavorite,
                      icon: Icon(_saved
                          ? Icons.favorite
                          : Icons.favorite_border),
                      label: const Text('Favorite'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}