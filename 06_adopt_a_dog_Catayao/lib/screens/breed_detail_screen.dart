import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/breed.dart';
import '../services/app_state.dart';
import '../services/dog_api_service.dart';

class BreedDetailScreen extends StatefulWidget {
  final Breed breed;

  const BreedDetailScreen({super.key, required this.breed});

  @override
  State<BreedDetailScreen> createState() => _BreedDetailScreenState();
}

class _BreedDetailScreenState extends State<BreedDetailScreen> {
  final DogApiService _dogApiService = DogApiService();
  final AppState _appState = AppState.instance;

  late Future<String> _imageFuture;
  String? _selectedSubBreed;

  @override
  void initState() {
    super.initState();
    _imageFuture = _createImageFuture();
    _appState.addRecentBreed(widget.breed.name);
  }

  Future<String> _createImageFuture() {
    return _dogApiService.fetchRandomImage(
      breed: widget.breed.name,
      subBreed: _selectedSubBreed,
    );
  }

  void _refreshImage() {
    setState(() {
      _imageFuture = _createImageFuture();
    });
  }

  void _setSubBreed(String? subBreed) {
    setState(() {
      _selectedSubBreed = subBreed;
      _imageFuture = _createImageFuture();
    });
  }

  Future<void> _toggleFavorite() async {
    final breedName = widget.breed.name;

    if (_appState.favorites.contains(breedName)) {
      await _appState.removeFavorite(breedName);
    } else {
      await _appState.addFavorite(breedName);
    }

    if (mounted) {
      final isFavorite = _appState.favorites.contains(breedName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? '$breedName saved!' : '$breedName removed.',
          ),
        ),
      );
    }
  }

  Widget _buildSubBreedSelector() {
    if (widget.breed.subBreeds.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: _selectedSubBreed == null,
              onSelected: (_) => _setSubBreed(null),
            ),
          ),
          ...widget.breed.subBreeds.map(
            (subBreed) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(subBreed),
                selected: _selectedSubBreed == subBreed,
                onSelected: (_) => _setSubBreed(subBreed),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _displayTitle {
    final breedName = widget.breed.name;
    return breedName[0].toUpperCase() + breedName.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final breedName = widget.breed.name;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        final isFavorite = _appState.favorites.contains(breedName);

        return Scaffold(
          appBar: AppBar(title: Text(_displayTitle)),
          body: FutureBuilder<String>(
            future: _imageFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              }

              final imageUrl = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayTitle,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedSubBreed == null
                              ? 'Viewing the main breed profile'
                              : 'Viewing the ${widget.breed.displayName(_selectedSubBreed)} profile',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _DetailBadge(
                              icon: Icons.account_tree_outlined,
                              label:
                                  '${widget.breed.subBreeds.length} sub-breeds',
                            ),
                            _DetailBadge(
                              icon: Icons.favorite_outline,
                              label:
                                  isFavorite ? 'Saved favorite' : 'Not saved yet',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSubBreedSelector(),
                  if (widget.breed.subBreeds.isNotEmpty)
                    const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      height: 320,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        height: 320,
                        color: const Color(0xFFFFE0B2),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 320,
                        color: const Color(0xFFFFE0B2),
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 64),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 360;

                      if (isCompact) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _refreshImage,
                                icon: const Icon(Icons.refresh),
                                label: const Text('New Photo'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: isFavorite ? null : _toggleFavorite,
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                                label: Text(isFavorite ? 'Saved' : 'Save'),
                              ),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _refreshImage,
                              icon: const Icon(Icons.refresh),
                              label: const Text('New Photo'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isFavorite ? null : _toggleFavorite,
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              label: Text(isFavorite ? 'Saved' : 'Save'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Why this breed stands out',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        const _FactRow(
                          icon: Icons.photo_library_outlined,
                          text:
                              'Refresh the photo anytime to explore more dogs from the same breed.',
                        ),
                        const _FactRow(
                          icon: Icons.tune_rounded,
                          text:
                              'If sub-breeds are available, switch chips to see more specific matches.',
                        ),
                        const _FactRow(
                          icon: Icons.favorite_rounded,
                          text:
                              'Save favorites so you can quickly compare breeds later.',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _DetailBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFEF6C00)),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
