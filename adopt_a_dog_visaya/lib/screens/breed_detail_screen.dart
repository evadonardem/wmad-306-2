import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/breed.dart';
import '../services/dog_api_service.dart';
import '../services/prefs_service.dart';

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
  String? _selectedSubBreed;
  bool _saved = false;

  String get _breedPath => _selectedSubBreed == null
      ? widget.breed.name
      : '${widget.breed.name}/$_selectedSubBreed';

  @override
  void initState() {
    super.initState();
    _imageFuture = _api.fetchRandomImage(widget.breed.name);
  }

  Future<void> _refreshImage() async {
    setState(() {
      _imageFuture = _api.fetchRandomImage(
        widget.breed.name,
        _selectedSubBreed,
      );
      _saved = false;
    });
  }

  Future<void> _saveFavorite() async {
    await _prefs.saveFavorite(_breedPath);
    if (mounted) {
      setState(() => _saved = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved as favorite!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.breed.name[0].toUpperCase() + widget.breed.name.substring(1)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.breed.subBreeds.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedSubBreed == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedSubBreed = null;
                              _imageFuture = _api.fetchRandomImage(widget.breed.name);
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ...widget.breed.subBreeds.map((sub) {
                        final selected = _selectedSubBreed == sub;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(sub),
                            selected: selected,
                            onSelected: (active) {
                              if (active) {
                                setState(() {
                                  _selectedSubBreed = sub;
                                  _imageFuture = _api.fetchRandomImage(widget.breed.name, sub);
                                });
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: FutureBuilder<String>(
                  future: _imageFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final imageUrl = snapshot.data;
                    if (imageUrl == null || imageUrl.isEmpty) {
                      return const Center(child: Text('No image available'));
                    }

                    return Center(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        memCacheWidth: 1080,
                        memCacheHeight: 1080,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.broken_image, size: 64),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Photo'),
                  onPressed: _refreshImage,
                ),
                ElevatedButton.icon(
                  icon: Icon(_saved ? Icons.favorite : Icons.favorite_border),
                  label: const Text('Favorite'),
                  onPressed: _saved ? null : _saveFavorite,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Selected path: $_breedPath',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
