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
    _loadImage();
  }

  void _loadImage() {
    _imageFuture =
        _api.fetchRandomImage(widget.breed.name, subBreed: _selectedSubBreed);
  }

  void _refresh() {
    setState(() {
      _imageFuture = _api.fetchRandomImage(widget.breed.name,
          subBreed: _selectedSubBreed);
      _saved = false;
    });
  }

  void _selectSubBreed(String? subBreed) {
    setState(() {
      _selectedSubBreed = subBreed;
      _saved = false;
    });
    _loadImage();
  }

  Future<void> _saveFavorite() async {
    String displayName = _selectedSubBreed != null
        ? widget.breed.displayName(sub: _selectedSubBreed)
        : widget.breed.name;

    await _prefs.addFavorite(displayName);
    setState(() => _saved = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$displayName saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            widget.breed.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        titleSpacing: 0,
        leadingWidth: 56,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _saveFavorite,
              icon: Icon(_saved ? Icons.favorite : Icons.favorite_border),
              style: IconButton.styleFrom(
                backgroundColor: _saved
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ✅ Varieties section
          if (widget.breed.subBreeds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Varieties:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF424242),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('All'),
                            selected: _selectedSubBreed == null,
                            onSelected: (_) => _selectSubBreed(null),
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFFE8F5E8),
                            checkmarkColor: const Color(0xFF2E7D32),
                            labelStyle: TextStyle(
                              color: _selectedSubBreed == null
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF424242),
                              fontWeight: FontWeight.w500,
                            ),
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                        ),
                        ...widget.breed.subBreeds.map(
                          (subBreed) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                subBreed[0].toUpperCase() +
                                    subBreed.substring(1),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                              selected: _selectedSubBreed == subBreed,
                              onSelected: (_) => _selectSubBreed(subBreed),
                              backgroundColor: Colors.white,
                              selectedColor: const Color(0xFFE8F5E8),
                              checkmarkColor: const Color(0xFF2E7D32),
                              labelStyle: TextStyle(
                                color: _selectedSubBreed == subBreed
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFF424242),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              side: const BorderSide(color: Color(0xFF4CAF50)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ✅ Image + buttons
          Expanded(
            child: FutureBuilder<String>(
              future: _imageFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF2E7D32),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('${snapshot.error}'),
                  );
                }

                final url = snapshot.data!;

                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.contain, // ✅ whole figure visible
                            width: double.infinity,
                            height: double.infinity,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _refresh,
                              icon: const Icon(Icons.refresh),
                              label: const Text('New Photo'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saved ? null : _saveFavorite,
                              icon: Icon(
                                  _saved ? Icons.favorite : Icons.favorite_border),
                              label: Text(_saved ? 'Saved' : 'Favorite'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
