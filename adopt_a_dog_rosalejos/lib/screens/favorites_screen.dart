import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/dog_api_service.dart';
import '../services/prefs_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _prefs = PrefsService();
  final _api = DogApiService();
  late Future<List<String>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoritesFuture = _prefs.loadFavorites();
    });
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

  Future<void> _removeFavorite(String breed) async {
    await _prefs.removeFavorite(breed);
    _loadFavorites();
  }

  void _showFullScreenImage(BuildContext context, String url) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, _, unused) => Scaffold(
          backgroundColor: Colors.black.withAlpha(217),
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
      appBar: AppBar(title: const Text('My Favorites')),
      body: FutureBuilder<List<String>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'Your pack is empty!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You haven\'t saved any furry friends yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.search),
                      label: const Text('Explore Breeds'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final breed = favorites[index];
              final isEven = index % 2 == 0;
              final bgColor = isEven ? const Color(0xFF424874) : const Color(0xFFA6B1E1);
              final contentColor = isEven ? const Color(0xFFDCD6F7) : const Color(0xFFF4EEFF);

              return FavoriteBreedCard(
                breed: breed,
                displayName: _toTitleCase(breed),
                api: _api,
                onDelete: () => _removeFavorite(breed),
                onImageTap: (url) => _showFullScreenImage(context, url),
                backgroundColor: bgColor,
                contentColor: contentColor,
              );
            },
          );
        },
      ),
    );
  }
}

class FavoriteBreedCard extends StatefulWidget {
  final String breed;
  final String displayName;
  final DogApiService api;
  final VoidCallback onDelete;
  final Function(String) onImageTap;
  final Color backgroundColor;
  final Color contentColor;

  const FavoriteBreedCard({
    super.key,
    required this.breed,
    required this.displayName,
    required this.api,
    required this.onDelete,
    required this.onImageTap,
    required this.backgroundColor,
    required this.contentColor,
  });

  @override
  State<FavoriteBreedCard> createState() => _FavoriteBreedCardState();
}

class _FavoriteBreedCardState extends State<FavoriteBreedCard> {
  bool _isHovered = false;
  late Future<String> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = widget.api.fetchRandomImage(widget.breed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38), // ~0.15 opacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: FutureBuilder<String>(
                  future: _imageFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Icon(Icons.error));
                    }
                    final url = snapshot.data!;
                    return GestureDetector(
                      onTap: () => widget.onImageTap(url),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? Colors.red.withAlpha(230) // ~0.9 opacity
                          : Colors.black.withAlpha(77), // ~0.3 opacity
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Colors.white),
                      onPressed: widget.onDelete,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.pets, color: widget.contentColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.displayName,
                    style: TextStyle(
                      color: widget.contentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
