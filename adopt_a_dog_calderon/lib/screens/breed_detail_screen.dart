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
  final List<String> _imageHistory = [];
  int _currentIndex = 0;
  double _dragStartPage = 0;
  late PageController _pageController;
  final _api = DogApiService();
  final _prefs = PrefsService();
  bool _saved = false;
  String? _selectedSubBreed;
  bool _drawerExpanded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadPersistence();
    _initImages();
  }

  Future<void> _initImages() async {
    await _fetchNewImage(); // Fetch first
    _fetchNewImage(); // Pre-fetch second
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPersistence() async {
    final drawerOpen = await _prefs.loadDrawerState();
    setState(() => _drawerExpanded = drawerOpen);
  }

  Future<void> _checkFavorite() async {
    if (_imageHistory.isEmpty || _currentIndex >= _imageHistory.length) return;
    final breedName = _getBreedName();
    final isFav = await _prefs.isFavorited(breedName);
    setState(() => _saved = isFav);
  }

  String _getBreedName() {
    return _selectedSubBreed == null
        ? widget.breed.name
        : '${_selectedSubBreed!} ${widget.breed.name}';
  }

  Future<void> _fetchNewImage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final path = _selectedSubBreed == null
        ? widget.breed.name
        : '${widget.breed.name}/$_selectedSubBreed';

    try {
      final url = await _api.fetchRandomImage(path);
      if (!_imageHistory.contains(url)) {
        setState(() {
          _imageHistory.add(url);
          _isLoading = false;
        });
        if (_imageHistory.length == 1) {
          _checkFavorite();
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSubBreedSelected(String? sub) {
    setState(() {
      _selectedSubBreed = sub;
      _imageHistory.clear();
      _currentIndex = 0;
      _dragStartPage = 0;
    });
    _initImages();
  }

  Future<void> _toggleFavorite() async {
    if (_imageHistory.isEmpty || _currentIndex >= _imageHistory.length) return;
    final breedName = _getBreedName();
    final url = _imageHistory[_currentIndex];
    final capitalizedName = breedName[0].toUpperCase() + breedName.substring(1);

    String message;
    if (_saved) {
      await _prefs.removeFavorite(breedName);
      setState(() => _saved = false);
      message = '$capitalizedName is removed from favorites!';
    } else {
      await _prefs.saveFavorite(breedName, url);
      setState(() => _saved = true);
      message = '$capitalizedName is added to favorites!';
    }
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFF38181),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 110, left: 16, right: 16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _addImageToGallery() async {
    if (_imageHistory.isEmpty || _currentIndex >= _imageHistory.length) return;
    final breedName = _getBreedName();
    final url = _imageHistory[_currentIndex];
    final capitalizedName = breedName[0].toUpperCase() + breedName.substring(1);

    await _prefs.addImageToGallery(breedName, url);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added new image to $capitalizedName gallery!'),
          backgroundColor: const Color(0xFFF38181),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 110, left: 16, right: 16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleDrawer(bool open) {
    setState(() => _drawerExpanded = open);
    _prefs.saveDrawerState(open);
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
      appBar: AppBar(
        title: Text(
          widget.breed.name[0].toUpperCase() + widget.breed.name.substring(1),
        ),
      ),
      body: Column(
        children: [
          if (widget.breed.subBreeds.isNotEmpty)
            Container(
              height: 60,
              color: Theme.of(context).colorScheme.tertiary,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Tooltip(
                        message: 'Click to expand',
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleDrawer(true),
                          icon: const Icon(Icons.pets),
                          label: const Text('Breeds'),
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _drawerExpanded
                        ? 0
                        : MediaQuery.of(context).size.width,
                    right: _drawerExpanded
                        ? 0
                        : -MediaQuery.of(context).size.width,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      color: Theme.of(context).colorScheme.tertiary,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _toggleDrawer(false),
                          ),
                          const Text(
                            'Breeds:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: ChoiceChip(
                                    label: const Text('Main'),
                                    selected: _selectedSubBreed == null,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    onSelected: (selected) {
                                      if (selected) _onSubBreedSelected(null);
                                    },
                                  ),
                                ),
                                ...widget.breed.subBreeds.map(
                                  (sub) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(
                                        sub[0].toUpperCase() + sub.substring(1),
                                      ),
                                      selected: _selectedSubBreed == sub,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      onSelected: (selected) {
                                        if (selected) _onSubBreedSelected(sub);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  _dragStartPage = _pageController.page ?? 0;
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: _imageHistory.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  _checkFavorite();
                  // Pre-fetch the next one if we are near the end
                  if (index >= _imageHistory.length - 1) {
                    _fetchNewImage();
                  }
                },
                itemBuilder: (context, index) {
                  final url = _imageHistory[index];
                  return GestureDetector(
                    onTap: () => _showFullScreenImage(url),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (ctx, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (ctx, url, err) =>
                          const Icon(Icons.broken_image, size: 64),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            height: 28, // Fixed height to prevent vertical jumping
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double page = _pageController.hasClients
                    ? (_pageController.page ?? 0)
                    : 0;

                double distFromInteger = (page - page.round()).abs();
                bool swipingNext = page > _dragStartPage; // Swipe Left gesture
                bool swipingPrev = page < _dragStartPage; // Swipe Right gesture

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    double size = 8.0;
                    Color color = Colors.grey.shade400;
                    double opacity = 1.0;

                    if (page <= 1.0 && _dragStartPage < 0.5) {
                      // Special handling for the very first page transition (0 -> 1)
                      if (index == 0) {
                        double active = (1.0 - page).clamp(0, 1);
                        size = 8.0 + (active * 4.0);
                        color = Color.lerp(
                          Colors.grey.shade400,
                          Theme.of(context).primaryColor,
                          active,
                        )!;
                      } else if (index == 1) {
                        double active = page.clamp(0, 1);
                        size = 8.0 + (active * 4.0);
                        color = Color.lerp(
                          Colors.grey.shade400,
                          Theme.of(context).primaryColor,
                          active,
                        )!;
                      } else if (index == 2) {
                        opacity = page.clamp(0, 1);
                      }
                    } else {
                      // General "Leaning" Logic
                      double weight = (distFromInteger * 2.0).clamp(0, 1);

                      if (distFromInteger < 0.01) {
                        // Resting state: Middle dot highlighted
                        if (index == 1) {
                          size = 12.0;
                          color = Theme.of(context).primaryColor;
                        }
                      } else {
                        // Swiping state
                        if (swipingNext) {
                          // Gesture Left -> Moving to Next -> Highlight RIGHT dot (index 2)
                          if (index == 2) {
                            size = 8.0 + (weight * 4.0);
                            color = Color.lerp(
                              Colors.grey.shade400,
                              Theme.of(context).primaryColor,
                              weight,
                            )!;
                          } else if (index == 1) {
                            size = 12.0 - (weight * 4.0);
                            color = Color.lerp(
                              Theme.of(context).primaryColor,
                              Colors.grey.shade400,
                              weight,
                            )!;
                          }
                        } else if (swipingPrev) {
                          // Gesture Right -> Moving to Prev -> Highlight LEFT dot (index 0)
                          if (index == 0) {
                            size = 8.0 + (weight * 4.0);
                            color = Color.lerp(
                              Colors.grey.shade400,
                              Theme.of(context).primaryColor,
                              weight,
                            )!;
                          } else if (index == 1) {
                            size = 12.0 - (weight * 4.0);
                            color = Color.lerp(
                              Theme.of(context).primaryColor,
                              Colors.grey.shade400,
                              weight,
                            )!;
                          }
                        }
                      }
                    }

                    return Opacity(
                      opacity: opacity,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: ElevatedButton.icon(
                    onPressed: _imageHistory.isEmpty ? null : _toggleFavorite,
                    icon: Icon(_saved ? Icons.favorite : Icons.favorite_border),
                    label: Text(_saved ? 'Unfavorite' : 'Favorite'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: !_saved ? null : _addImageToGallery,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Image'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
