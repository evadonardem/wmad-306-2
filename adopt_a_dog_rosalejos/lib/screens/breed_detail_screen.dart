import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  String? _selectedSubBreed;
  bool _isSubBreedsExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
    _checkIfSaved();
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  void _loadImage() {
    String path = widget.breed.name;
    if (_selectedSubBreed != null) {
      path = '${widget.breed.name}/$_selectedSubBreed';
    }
    _imageFuture = _api.fetchRandomImage(path);
  }

  Future<void> _checkIfSaved() async {
    final favorites = await _prefs.loadFavorites();
    if (mounted) {
      setState(() {
        _saved = favorites.contains(widget.breed.name);
      });
    }
  }

  void _refresh() => setState(() {
        _loadImage();
      });

  void _onSubBreedSelected(String? subBreed) {
    setState(() {
      _selectedSubBreed = subBreed;
      _isSubBreedsExpanded = false;
      _loadImage();
    });
  }

  Future<void> _toggleFavorite() async {
    final breedTitle = _toTitleCase(widget.breed.name);
    if (_saved) {
      await _prefs.removeFavorite(widget.breed.name);
      if (mounted) {
        setState(() => _saved = false);
        _showFloatingSnackBar('$breedTitle removed from favorites');
      }
    } else {
      await _prefs.saveFavorite(widget.breed.name);
      if (mounted) {
        setState(() => _saved = true);
        _showFloatingSnackBar('$breedTitle saved!');
      }
    }
  }

  void _showFloatingSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        width: 250,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFullScreenImage(String url) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, _, unused) => Scaffold(
          backgroundColor: Colors.black.withAlpha(217), // ~0.85 opacity
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_toTitleCase(widget.breed.name))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Left Side: Sub-breed and Favorite Buttons
            SizedBox(
              width: 150,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.breed.subBreeds.isNotEmpty && _isSubBreedsExpanded)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26), // ~0.1 opacity
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        children: [
                          ListTile(
                            title: const Text('All'),
                            selected: _selectedSubBreed == null,
                            onTap: () => _onSubBreedSelected(null),
                            dense: true,
                          ),
                          ...widget.breed.subBreeds.map((sub) => ListTile(
                                title: Text(_toTitleCase(sub)),
                                selected: _selectedSubBreed == sub,
                                onTap: () => _onSubBreedSelected(sub),
                                dense: true,
                              )),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.breed.subBreeds.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: FloatingActionButton(
                                heroTag: 'subBreedFAB',
                                onPressed: () => setState(() {
                                  _isSubBreedsExpanded = !_isSubBreedsExpanded;
                                }),
                                backgroundColor: Colors.deepPurpleAccent,
                                foregroundColor: Colors.white,
                                mini: true,
                                child: Icon(_isSubBreedsExpanded
                                    ? Icons.close
                                    : Icons.list_alt_rounded),
                              ),
                            ),
                          FloatingActionButton(
                            heroTag: 'favoriteFAB',
                            onPressed: _toggleFavorite,
                            backgroundColor: _saved
                                ? const Color(0xFFFF4D6D)
                                : Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            child: Icon(_saved
                                ? Icons.favorite
                                : Icons.favorite_border),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Right Side: Next Button
            FloatingActionButton(
              heroTag: 'nextFAB',
              onPressed: _refresh,
              backgroundColor: Colors.deepPurpleAccent,
              foregroundColor: Colors.white,
              child: const Icon(Icons.navigate_next),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<String>(
              future: _imageFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return _buildSkeletonLoader();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }
                final url = snapshot.data!;
                return GestureDetector(
                  onTap: () => _showFullScreenImage(url),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) =>
                        _buildSkeletonLoader(), // Using skeleton as placeholder too
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, size: 64),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                color: Colors.deepPurpleAccent.withAlpha(100),
                backgroundColor: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
