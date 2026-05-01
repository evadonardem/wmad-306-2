import 'package:adopt_a_dog/models/breed.dart';
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
        _imageFuture = _api.fetchRandomImage(_selectedSubBreed != null 
            ? "${widget.breed.name}/$_selectedSubBreed" 
            : widget.breed.name);
        _saved = false;
      });

  Future<void> _saveFavorite() async {
    final breedToSave = _selectedSubBreed != null 
        ? "${widget.breed.name}/$_selectedSubBreed" 
        : widget.breed.name;
    await _prefs.saveFavorite(breedToSave);
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.breed.displayName(sub: _selectedSubBreed)} saved!')),
      );
    }
  }

  void _selectSubBreed(String? subBreed) {
    setState(() {
      _selectedSubBreed = subBreed;
      _imageFuture = _api.fetchRandomImage(subBreed != null 
          ? "${widget.breed.name}/$subBreed" 
          : widget.breed.name);
      _saved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.breed.displayName(sub: _selectedSubBreed))),
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
              // Sub-breed chips row - only show if breed has sub-breeds
              if (widget.breed.subBreeds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // "All" chip to show parent breed
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedSubBreed == null,
                        onSelected: (selected) => _selectSubBreed(null),
                      ),
                      // Individual sub-breed chips
                      for (final sub in widget.breed.subBreeds)
                        ChoiceChip(
                          label: Text(sub),
                          selected: _selectedSubBreed == sub,
                          onSelected: (selected) => _selectSubBreed(sub),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 64),
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
