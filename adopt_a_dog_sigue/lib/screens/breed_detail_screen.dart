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
  final _api = DogApiService();
  final _prefs = PrefsService();
  bool _saved = false;
  String? _selectedSubBreed;

  @override
  void initState() {
    super.initState();
    _imageFuture = _api.fetchRandomImage(widget.breed.name);
  }

  String _currentBreedPath() {
    if (_selectedSubBreed != null) {
      return '${widget.breed.name}/${_selectedSubBreed!}';
    }
    return widget.breed.name;
  }

  void _refresh() => setState(() {
    _imageFuture = _api.fetchRandomImage(_currentBreedPath());
    _saved = false;
  });

  void _onChipTapped(String? sub) {
    setState(() {
      _selectedSubBreed = sub;
      _imageFuture = _api.fetchRandomImage(_currentBreedPath());
      _saved = false;
    });
  }

  Future<void> _saveFavorite() async {
    await _prefs.saveFavorite(widget.breed.name);
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${widget.breed.name} saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final subBreeds = widget.breed.subBreeds;

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
              if (subBreeds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(widget.breed.name),
                            selected: _selectedSubBreed == null,
                            onSelected: (_) => _onChipTapped(null),
                          ),
                        ),
                        ...subBreeds.map(
                          (sub) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(sub),
                              selected: _selectedSubBreed == sub,
                              onSelected: (_) => _onChipTapped(sub),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // CachedNetworkImage replaces Image.network
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (ctx, url) =>
                      const Center(child: CircularProgressIndicator()),
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
