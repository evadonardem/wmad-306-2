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

class _BreedDetailScreenState extends State<BreedDetailScreen>
    with TickerProviderStateMixin {
  late Future<String> _imageFuture;
  final _api = DogApiService();
  final _prefs = PrefsService();
  bool _saved = false;
  String? _selectedSubBreed;
  late AnimationController _favoriteController;
  late AnimationController _imageController;

  @override
  void initState() {
    super.initState();
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadImage();
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _loadImage() {
    final breedName = _selectedSubBreed != null
        ? '${widget.breed.name}-$_selectedSubBreed'
        : widget.breed.name;
    _imageFuture = _api.fetchRandomImage(breedName);
  }

  void _refresh() {
    _imageController.forward(from: 0.0);
    setState(() {
      final breedName = _selectedSubBreed != null
          ? '${widget.breed.name}-$_selectedSubBreed'
          : widget.breed.name;
      _imageFuture = _api.fetchRandomImage(breedName);
      _saved = false;
    });
  }

  void _selectSubBreed(String? subBreed) {
    _imageController.forward(from: 0.0);
    setState(() {
      _selectedSubBreed = subBreed;
      _saved = false;
    });
    _loadImage();
  }

  Future<void> _saveFavorite() async {
    String displayName = _selectedSubBreed != null
        ? widget.breed.displayName(_selectedSubBreed)
        : widget.breed.name;

    await _prefs.saveFavorite(displayName);
    _favoriteController.forward(from: 0.0);
    setState(() => _saved = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$displayName saved!'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: Text(
          widget.breed.name[0].toUpperCase() + widget.breed.name.substring(1),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          ScaleTransition(
            scale: Tween<double>(begin: 1, end: 1.3).animate(
              CurvedAnimation(parent: _favoriteController, curve: Curves.elasticOut),
            ),
            child: IconButton(
              onPressed: _saveFavorite,
              icon: Icon(_saved ? Icons.favorite : Icons.favorite_border),
              color: _saved ? Colors.redAccent : Colors.grey[700],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sub-breed chips
          if (widget.breed.subBreeds.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedSubBreed == null,
                    onSelected: (_) => _selectSubBreed(null),
                    selectedColor: Colors.green[100],
                    checkmarkColor: Colors.green[800],
                  ),
                  ...widget.breed.subBreeds.map(
                    (sub) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text(sub[0].toUpperCase() + sub.substring(1)),
                        selected: _selectedSubBreed == sub,
                        onSelected: (_) => _selectSubBreed(sub),
                        selectedColor: Colors.green[100],
                        checkmarkColor: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Image + buttons
          Expanded(
            child: FutureBuilder<String>(
              future: _imageFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.red[700], fontSize: 16),
                    ),
                  );
                }

                final url = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Card for image
                      Expanded(
                        child: FadeTransition(
                          opacity: Tween<double>(begin: 0.5, end: 1).animate(
                            CurvedAnimation(
                              parent: _imageController,
                              curve: Curves.easeIn,
                            ),
                          ),
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.85, end: 1).animate(
                              CurvedAnimation(
                                parent: _imageController,
                                curve: Curves.easeOutBack,
                              ),
                            ),
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              clipBehavior: Clip.antiAlias,
                              child: CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (ctx, url) =>
                                    const Center(child: CircularProgressIndicator()),
                                errorWidget: (ctx, url, error) =>
                                    const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Action buttons
                      SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                          CurvedAnimation(
                            parent: _imageController,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _refresh,
                                icon: const Icon(Icons.refresh),
                                label: const Text('New Photo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saved ? null : _saveFavorite,
                                icon: Icon(
                                    _saved ? Icons.favorite : Icons.favorite_border),
                                label: Text(_saved ? 'Saved' : 'Favorite'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _saved ? Colors.grey[400] : Colors.redAccent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}