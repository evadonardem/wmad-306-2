import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/models/favorite.dart';
import 'package:adopt_a_dog/services/dog_api_service.dart';
import 'package:adopt_a_dog/services/prefs_service.dart';
import 'package:flutter/material.dart';
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
    _imageFuture = _api.fetchRandomImage(widget.breed.name);
  }

  void _refresh() => setState(() {
    _imageFuture = _api.fetchRandomImage(widget.breed.name);
    _saved = false;
  });

  Future<void> _saveFavorite() async {
    // Get the current image URL from the future
    final currentImageUrl = await _imageFuture;
    
    // Create a Favorite object with breed name and current image URL
    final favorite = Favorite(
      breedName: widget.breed.name,
      imageUrl: currentImageUrl,
    );
    
    await _prefs.saveFavorite(favorite);
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.breed.name} added to favorites!')),
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
              // Exercise 1: Sub-Breed Support
              if (widget.breed.subBreeds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Main breed chip
                      ChoiceChip(
                        label: Text('All ${widget.breed.name}'),
                        selected: _selectedSubBreed == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedSubBreed = null;
                              _imageFuture = _api.fetchRandomImage(
                                widget.breed.name,
                              );
                              _saved = false;
                            });
                          }
                        },
                      ),
                      // Sub-breed chips
                      for (final sub in widget.breed.subBreeds)
                        ChoiceChip(
                          label: Text(sub[0].toUpperCase() + sub.substring(1)),
                          selected: _selectedSubBreed == sub,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedSubBreed = sub;
                                _imageFuture = _api.fetchRandomImage(
                                  '${widget.breed.name}/$sub',
                                );
                                _saved = false;
                              });
                            }
                          },
                        ),
                    ],
                  ),
                ),
              // Make image scrollable to see full picture
              Expanded(
                child: SingleChildScrollView(
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.6,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, size: 64),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _saved ? null : _saveFavorite,
                      icon: Icon(
                        _saved ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                      ),
                      label: const Text('Favorite', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: Colors.red,
                      ),
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
