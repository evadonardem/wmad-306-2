import 'package:adopt_a_dog/services/dog_api_service.dart';
import 'package:adopt_a_dog/services/prefs_service.dart';
import 'package:adopt_a_dog/models/breed.dart';
import 'package:flutter/material.dart';

class BreedDetailScreen extends StatefulWidget {
  final Breed breed;
  const BreedDetailScreen({super.key, required this.breed});

  @override
  State<BreedDetailScreen> createState() => _BreedDetailScreenState();
}

class _BreedDetailScreenState extends State<BreedDetailScreen> {
  late Future<String> _imageFuture;
  bool _isFavorite = false;
  Size? _imageSize;
  String? _currentImageUrl;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  @override
  void initState() {
    super.initState();
    _imageFuture = DogApiService().fetchRandomImage(widget.breed.name);
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final favorites = await PrefsService().loadFavorites();
    if (mounted) {
      setState(() {
        _isFavorite = favorites.contains(widget.breed.name);
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await PrefsService().removeFavorite(widget.breed.name);
    } else {
      await PrefsService().addFavorite(widget.breed.name);
    }
    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? '${widget.breed.name} added to favorites' : '${widget.breed.name} removed from favorites',
          ),
        ),
      );
    }
  }

  void _resolveImageSize(String imageUrl) {
    if (_currentImageUrl == imageUrl) return;

    _currentImageUrl = imageUrl;
    _imageSize = null;

    final oldListener = _imageStreamListener;
    if (_imageStream != null && oldListener != null) {
      _imageStream!.removeListener(oldListener);
    }

    _imageStreamListener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) {
        if (!mounted) return;
        setState(() {
          _imageSize = Size(
            imageInfo.image.width.toDouble(),
            imageInfo.image.height.toDouble(),
          );
        });
      },
      onError: (_, __) {
        // Ignore errors for sizing; fallback will continue to show the image.
      },
    );

    final provider = NetworkImage(imageUrl);
    _imageStream = provider.resolve(const ImageConfiguration());
    _imageStream?.addListener(_imageStreamListener!);
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.breed.displayName()),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _imageFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      height: 450,
                      width: double.infinity,
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: SizedBox(
                      height: 720,
                      width: double.infinity,
                      child: Text('Failed to load image'),
                    ),
                  );
                } else {
                  _resolveImageSize(snapshot.data!);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.grey.shade200,
                      width: double.infinity,
                      child: _imageSize != null
                          ? AspectRatio(
                              aspectRatio: _imageSize!.width / _imageSize!.height,
                              child: Image.network(
                                snapshot.data!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            )
                          : SizedBox(
                              height: 520,
                              child: Image.network(
                                snapshot.data!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            ),
                    ),
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
              widget.breed.displayName(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            if (widget.breed.subBreeds.isNotEmpty) ...[
              Text(
                'Sub-breeds:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.breed.subBreeds.map((sub) {
                  return Chip(
                    label: Text(sub),
                    backgroundColor: Colors.green.shade100,
                  );
                }).toList(),
              ),
            ] else
              const Text('No sub-breeds available.'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _imageFuture = DogApiService().fetchRandomImage(widget.breed.name);
                  });
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Load Another Image'),
            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
