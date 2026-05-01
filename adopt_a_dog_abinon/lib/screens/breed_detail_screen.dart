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
  String? _selectedSubBreed;

  final _api = DogApiService();
  final _prefs = PrefsService();

  bool _saved = false;

  String get _breedPath {
    if (_selectedSubBreed == null || _selectedSubBreed!.isEmpty) {
      return widget.breed.name;
    }
    return '${widget.breed.name}/${_selectedSubBreed!}';
  }

  String get _readableName {
    if (_selectedSubBreed == null || _selectedSubBreed!.isEmpty) {
      return widget.breed.name;
    }
    return '${_selectedSubBreed!} ${widget.breed.name}';
  }

  @override
  void initState() {
    super.initState();
    _imageFuture = _api.fetchRandomImage(_breedPath);
  }

  void _refresh() {
    setState(() {
      _imageFuture = _api.fetchRandomImage(_breedPath);
      _saved = false;
    });
  }

  void _selectSubBreed(String? subBreed) {
    setState(() {
      _selectedSubBreed = subBreed;
      _imageFuture = _api.fetchRandomImage(_breedPath);
      _saved = false;
    });
  }

  Future<void> _saveFavorite() async {
    await _prefs.saveFavorite(_breedPath);

    setState(() => _saved = true);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$_readableName saved!')));
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
              if (widget.breed.subBreeds.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: widget.breed.subBreeds.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ChoiceChip(
                          label: Text(widget.breed.name),
                          selected: _selectedSubBreed == null,
                          onSelected: (_) => _selectSubBreed(null),
                        );
                      }
                      final sub = widget.breed.subBreeds[index - 1];
                      return ChoiceChip(
                        label: Text(sub),
                        selected: _selectedSubBreed == sub,
                        onSelected: (_) => _selectSubBreed(sub),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                height: 300,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.broken_image, size: 64)),
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
