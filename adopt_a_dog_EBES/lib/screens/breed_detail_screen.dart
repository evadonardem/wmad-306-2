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

  bool _saved = false;

  // Exercise 1 — currently selected sub-breed (null = parent breed)
  String? _selectedSubBreed;

  @override
  void initState() {
    super.initState();
    _imageFuture = _api.fetchRandomImage(widget.breed.name);
  }

  void _refresh() {
    setState(() {
      _imageFuture = _api.fetchRandomImage(
        widget.breed.name,
        subBreed: _selectedSubBreed,
      );
      _saved = false;
    });
  }

  // Exercise 1 — tap a chip to switch to that sub-breed image
  void _selectSubBreed(String? sub) {
    setState(() {
      _selectedSubBreed = sub;
      _imageFuture = _api.fetchRandomImage(
        widget.breed.name,
        subBreed: sub,
      );
      _saved = false;
    });
  }

  Future<void> _saveFavorite() async {
    await _prefs.saveFavorite(widget.breed.name);
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.breed.name} saved to favorites!')),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final subBreeds = widget.breed.subBreeds;

    return Scaffold(
      appBar: AppBar(
        title: Text(_capitalize(widget.breed.name)),
      ),
      body: FutureBuilder<String>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final url = snapshot.data!;

          return Column(
            children: [
              // Exercise 1 — sub-breed chip row (only when sub-breeds exist)
              if (subBreeds.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // "All" chip — shows parent breed image
                        ChoiceChip(
                          label: Text(_capitalize(widget.breed.name)),
                          selected: _selectedSubBreed == null,
                          onSelected: (_) => _selectSubBreed(null),
                        ),
                        const SizedBox(width: 6),
                        ...subBreeds.map(
                          (sub) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(_capitalize(sub)),
                              selected: _selectedSubBreed == sub,
                              onSelected: (_) => _selectSubBreed(sub),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Exercise 3 — CachedNetworkImage replaces Image.network
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (ctx, _) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (ctx, _, _) =>
                      const Center(child: Icon(Icons.broken_image, size: 64)),
                ),
              ),

              // Action buttons
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
                      icon: Icon(
                        _saved ? Icons.favorite : Icons.favorite_border,
                      ),
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
