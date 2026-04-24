import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/prefs_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _prefs = PrefsService();
  late Future<List<String>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _prefs.loadFavorites();
  }

  void _refreshFavorites() {
    setState(() {
      _favoritesFuture = _prefs.loadFavorites();
    });
  }

  Future<void> _removeFavorite(String breed) async {
    await _prefs.removeFavorite(breed);
    _refreshFavorites();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$breed removed from favorites')));
    }
  }

  void _showGallery(BuildContext context, String breed) async {
    List<String> gallery = await _prefs.loadGallery(breed);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: const Color(0xFFEAFFD0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                '${breed[0].toUpperCase()}${breed.substring(1)} Gallery',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: gallery.isEmpty
                    ? const Center(child: Text('No images in gallery.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: gallery.length,
                        itemBuilder: (context, index) {
                          final imageUrl = gallery[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                GestureDetector(
                                  onTap: () => _showFullScreenImage(imageUrl),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (ctx, url) =>
                                        Container(color: Colors.grey[200]),
                                  ),
                                ),
                                // Set as Thumbnail Button (Top Left)
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.photo_library,
                                          size: 18, color: Colors.white),
                                      tooltip: 'Set as Thumbnail',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                          minWidth: 32, minHeight: 32),
                                      onPressed: () async {
                                        await _prefs.setThumbnail(
                                            breed, imageUrl);
                                        _refreshFavorites();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Thumbnail updated!'),
                                                behavior: SnackBarBehavior.floating,
                                                duration: Duration(seconds: 1)),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                // Delete Button (Bottom Right)
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 18, color: Colors.white),
                                      tooltip: 'Remove from Gallery',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                          minWidth: 32, minHeight: 32),
                                      onPressed: () async {
                                        await _prefs.removeImageFromGallery(
                                            breed, imageUrl);
                                        final updated =
                                            await _prefs.loadGallery(breed);
                                        setModalState(() => gallery = updated);
                                        _refreshFavorites();
                                      },
                                    ),
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
        ),
      ),
    );
  }
  void _showFullScreenImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (ctx, url) => const CircularProgressIndicator(),
              errorWidget: (ctx, url, err) =>
                  const Icon(Icons.broken_image, color: Colors.white),
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    LinearProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading favorites...',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }
          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE38A).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 80,
                        color: Color(0xFFF38181),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Dogs Yet!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF38181),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your favorite doggos will appear here. Start exploring and tap the heart to save them here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.search),
                      label: const Text('Find a Breed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF95E1D3),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
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
            padding: const EdgeInsets.all(12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favoriteData = favorites[index];
              final parts = favoriteData.split('|');
              final breed = parts[0];
              final imageUrl = parts.length > 1 ? parts[1] : null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  height: 200, // Fixed height for consistency in list
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? const Color(0xFF95E1D3)
                        : const Color(0xFFFCE38A),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: FavoriteBreedTile(
                    breed: breed,
                    imageUrl: imageUrl,
                    onRemove: () => _removeFavorite(breed),
                    onTap: () => _showGallery(context, breed),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FavoriteBreedTile extends StatelessWidget {
  final String breed;
  final String? imageUrl;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const FavoriteBreedTile({
    super.key,
    required this.breed,
    this.imageUrl,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: onTap,
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            LinearProgressIndicator(),
                            SizedBox(height: 8),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    errorWidget: (ctx, url, err) =>
                        const Icon(Icons.broken_image),
                  )
                : const Center(child: Icon(Icons.broken_image)),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              color: Colors.black54,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      breed.toUpperCase()[0] + breed.substring(1),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onRemove,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
