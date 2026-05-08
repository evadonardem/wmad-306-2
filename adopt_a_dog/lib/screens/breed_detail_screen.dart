import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/services/dog_api_service.dart';
import 'package:adopt_a_dog/services/prefs_service.dart';
import 'package:flutter/material.dart';

class BreedDetailScreen extends StatefulWidget {
  final Breed breed;
  const BreedDetailScreen({super.key, required this.breed});

  @override
  State<BreedDetailScreen> createState() => _BreedDetailScreenState();
}

class _BreedDetailScreenState extends State<BreedDetailScreen> {
  final _api = DogApiService();
  final _prefs = PrefsService();
  String? _imageUrl;
  String? _selectedSubBreed;
  String? _favorite;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final favorite = await _prefs.loadFavorite();
      final imageUrl = await _api.fetchRandomImage(widget.breed.name, subBreed: _selectedSubBreed);
      setState(() {
        _favorite = favorite;
        _imageUrl = imageUrl;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _setFavorite() async {
    final displayName = widget.breed.displayName(sub: _selectedSubBreed);
    await _prefs.saveFavorite(displayName);
    if (mounted) {
      setState(() {
        _favorite = displayName;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$displayName set as favorite!')),
      );
    }
  }

  Future<void> _changeImage() async {
    setState(() {
      _loading = true;
    });
    try {
      final imageUrl = await _api.fetchRandomImage(widget.breed.name, subBreed: _selectedSubBreed);
      setState(() {
        _imageUrl = imageUrl;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _selectSubBreed(String? sub) {
    setState(() {
      _selectedSubBreed = sub;
    });
    _changeImage();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.breed.displayName(sub: _selectedSubBreed);
    final isFavorite = _favorite == displayName;

    return Scaffold(
      appBar: AppBar(title: Text(displayName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_imageUrl != null)
                    Center(
                      child: Column(
                        children: [
                          Image.network(_imageUrl!, height: 200),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _changeImage,
                            child: const Text('New Image'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (widget.breed.subBreeds.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Sub-breeds:'),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedSubBreed == null,
                          onSelected: (_) => _selectSubBreed(null),
                        ),
                        ...widget.breed.subBreeds.map(
                          (sub) => FilterChip(
                            label: Text(sub),
                            selected: _selectedSubBreed == sub,
                            onSelected: (_) => _selectSubBreed(sub),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: isFavorite ? null : _setFavorite,
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                    label: Text(isFavorite ? 'Favorite' : 'Set as Favorite'),
                  ),
                ],
              ),
            ),
    );
  }
}
