import 'package:flutter/material.dart';

import '../models/breed.dart';
import '../screens/breed_detail_screen.dart';
import '../services/dog_api_service.dart';
import '../services/prefs_service.dart';
import '../widgets/dog_image_viewer.dart';

// Ex2: FavoritesScreen now shows a scrollable list of all saved favorites.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _prefs = PrefsService();
  final _api = DogApiService();
  List<String> _favorites = [];
  final Set<String> _expanded = <String>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await _prefs.loadFavorites();
    if (mounted) {
      setState(() {
        _favorites = favs;
        _loading = false;
      });
    }
  }

  Future<void> _deleteFavorite(String breed) async {
    await _prefs.removeFavorite(breed);
    if (mounted) {
      setState(() {
        _favorites.remove(breed);
        _expanded.remove(breed);
      });
    }
  }

  void _toggleExpanded(String breed) {
    setState(() {
      if (_expanded.contains(breed)) {
        _expanded.remove(breed);
      } else {
        _expanded.add(breed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favorites.isEmpty) {
      return const Center(
        child: Text('No favorites saved yet!\nTap ♥ on any breed photo.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: _favorites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final breed = _favorites[index];
        final isExpanded = _expanded.contains(breed);
        final traits = _traitsForBreedName(breed);

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _toggleExpanded(breed),
            child: Column(
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minLeadingWidth: 72,
                  leading: SizedBox(
                    width: 72,
                    height: 64,
                    child: FutureBuilder<String>(
                      future: _api.fetchRandomImage(breed),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(
                              child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ));
                        }

                        if (snapshot.hasError || snapshot.data == null) {
                          return const Icon(Icons.pets, size: 36);
                        }

                        return Hero(
                          tag: 'hero-match-$breed',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 72,
                              height: 64,
                              child: DogImageViewer(
                                  imageUrl: snapshot.data!, height: 64),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  title: Text(_capitalise(breed)),
                  subtitle: const Text('Tap to view dog details'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Remove',
                        onPressed: () => _deleteFavorite(breed),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _TraitPill(
                              icon: Icons.directions_run,
                              label: 'Lifestyle: ${traits.lifestyle}',
                              tone: _lifestyleTone(traits.lifestyle),
                            ),
                            _TraitPill(
                              icon: Icons.brush,
                              label: 'Grooming: ${traits.grooming}',
                              tone: _groomingTone(traits.grooming),
                            ),
                            _TraitPill(
                              icon: Icons.straighten,
                              label: 'Size: ${traits.size}',
                              tone: _sizeTone(traits.size),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          traits.summary,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BreedDetailScreen(
                                  breed: Breed(name: breed, subBreeds: []),
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('View details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BreedTraits {
  const _BreedTraits({
    required this.lifestyle,
    required this.grooming,
    required this.size,
    required this.summary,
  });

  final String lifestyle;
  final String grooming;
  final String size;
  final String summary;
}

const Map<String, _BreedTraits> _knownTraits = {
  'basenji': _BreedTraits(
    lifestyle: 'Active',
    grooming: 'Low',
    size: 'Small-Medium',
    summary: 'Independent and energetic; needs daily play and brisk walks.',
  ),
  'pug': _BreedTraits(
    lifestyle: 'Relaxed',
    grooming: 'Low-Medium',
    size: 'Small',
    summary: 'Affectionate companion that prefers moderate activity.',
  ),
  'retriever': _BreedTraits(
    lifestyle: 'Active',
    grooming: 'Medium',
    size: 'Large',
    summary: 'Friendly, trainable, and happiest with regular exercise.',
  ),
  'husky': _BreedTraits(
    lifestyle: 'Very Active',
    grooming: 'High',
    size: 'Medium-Large',
    summary: 'Athletic breed with high stamina and heavy coat upkeep.',
  ),
  'bulldog': _BreedTraits(
    lifestyle: 'Relaxed',
    grooming: 'Low',
    size: 'Medium',
    summary: 'Calm and people-oriented; enjoys shorter low-impact outings.',
  ),
  'sheepdog': _BreedTraits(
    lifestyle: 'Active',
    grooming: 'High',
    size: 'Large',
    summary: 'Intelligent worker that needs frequent mental and coat care.',
  ),
  'chihuahua': _BreedTraits(
    lifestyle: 'Moderate',
    grooming: 'Low',
    size: 'Small',
    summary: 'Compact watchdog with bursts of energy and close bonding.',
  ),
  'beagle': _BreedTraits(
    lifestyle: 'Active',
    grooming: 'Low',
    size: 'Medium',
    summary: 'Curious scent hound that needs walks and sniff-heavy play.',
  ),
};

_BreedTraits _traitsForBreedName(String breedName) {
  final name = breedName.toLowerCase();
  final known = _knownTraits[name];
  if (known != null) return known;

  final size = _inferSize(name);
  final grooming = _inferGrooming(name);
  final lifestyle = _inferLifestyle(name);

  return _BreedTraits(
    lifestyle: lifestyle,
    grooming: grooming,
    size: size,
    summary:
        'Typical $size breed with $lifestyle lifestyle needs and $grooming grooming care.',
  );
}

String _inferSize(String name) {
  if (_containsAny(name, const ['mastiff', 'danish', 'newfoundland', 'bernese'])) {
    return 'Large';
  }
  if (_containsAny(name, const ['pug', 'chihuahua', 'maltese', 'papillon', 'pomeranian'])) {
    return 'Small';
  }
  return 'Medium';
}

String _inferGrooming(String name) {
  if (_containsAny(name, const ['poodle', 'sheepdog', 'maltese', 'husky', 'setter'])) {
    return 'High';
  }
  if (_containsAny(name, const ['retriever', 'spaniel', 'collie'])) {
    return 'Medium';
  }
  return 'Low';
}

String _inferLifestyle(String name) {
  if (_containsAny(name, const ['husky', 'kelpie', 'malinois', 'shepherd', 'collie'])) {
    return 'Very Active';
  }
  if (_containsAny(name, const ['pug', 'bulldog', 'basset', 'mastiff'])) {
    return 'Relaxed';
  }
  return 'Active';
}

bool _containsAny(String name, List<String> terms) {
  for (final term in terms) {
    if (name.contains(term)) return true;
  }
  return false;
}

Color _lifestyleTone(String value) {
  final v = value.toLowerCase();
  if (v.contains('very')) return Colors.deepOrange;
  if (v.contains('relaxed')) return Colors.blueGrey;
  if (v.contains('moderate')) return Colors.indigo;
  return Colors.teal;
}

Color _groomingTone(String value) {
  final v = value.toLowerCase();
  if (v.contains('high')) return Colors.purple;
  if (v.contains('medium')) return Colors.amber.shade800;
  return Colors.green.shade700;
}

Color _sizeTone(String value) {
  final v = value.toLowerCase();
  if (v.contains('large')) return Colors.brown;
  if (v.contains('small')) return Colors.teal;
  return Colors.blue;
}

class _TraitPill extends StatelessWidget {
  const _TraitPill({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.16),
        border: Border.all(color: tone.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tone),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: tone, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

String _capitalise(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
