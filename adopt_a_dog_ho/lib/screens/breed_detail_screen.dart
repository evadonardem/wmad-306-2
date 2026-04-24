import 'package:adopt_a_dog/models/breed.dart';
import 'package:flutter/material.dart';

import '../services/dog_api_service.dart';
import '../services/prefs_service.dart';
// Using inline Image.network with loading/error builders and fullscreen viewer

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

  // Ex1: currently selected sub-breed (null = parent breed)
  String? _selectedSub;

  @override
  void initState() {
    super.initState();
    _imageFuture = _api.fetchRandomImage(widget.breed.name);
  }

  /// Returns the API path for the current selection:
  /// 'hound' or 'hound/afghan' depending on chip state.
  String get _currentPath => _selectedSub != null
      ? '${widget.breed.name}/$_selectedSub'
      : widget.breed.name;

  void _refresh() {
    setState(() {
      _imageFuture = _api.fetchRandomImage(_currentPath);
      _saved = false;
    });
  }

  Future<void> _saveFavorite() async {
    await _prefs.saveFavorite(widget.breed.name);

    if (!mounted) return;

    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_capitalise(widget.breed.name)} saved!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Ex1: chip row — only shown when the breed has sub-breeds
  Widget _buildChipRow() {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: widget.breed.subBreeds.map((sub) {
          final isSelected = _selectedSub == sub;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_capitalise(sub)),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  // Toggle off if the same chip is tapped again
                  _selectedSub = isSelected ? null : sub;
                  _imageFuture = _api.fetchRandomImage(_currentPath);
                  _saved = false;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_capitalise(widget.breed.name))),
      body: Column(
        children: [
          // Ex1: chip row only for breeds that have sub-breeds
          if (widget.breed.subBreeds.isNotEmpty) _buildChipRow(),

          Expanded(
            child: FutureBuilder<String>(
              future: _imageFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }

                final url = snapshot.data!;

                return Hero(
                  tag: 'hero-match-${widget.breed.name}',
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => Dialog(
                          insetPadding: EdgeInsets.zero,
                          child: GestureDetector(
                            onTap: () => Navigator.of(ctx).pop(),
                            child: InteractiveViewer(
                              child: Hero(
                                tag: 'hero-match-${widget.breed.name}',
                                child: Image.network(
                                  url,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stack) => const Center(
                                    child: Icon(Icons.broken_image, size: 64),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stack) => const Center(
                        child: Icon(Icons.broken_image, size: 64),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Details section (copied style from favorites)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _TraitPill(
                      icon: Icons.directions_run,
                      label: 'Lifestyle: ${_traitsForBreedName(widget.breed.name).lifestyle}',
                      tone: _lifestyleTone(_traitsForBreedName(widget.breed.name).lifestyle),
                    ),
                    _TraitPill(
                      icon: Icons.brush,
                      label: 'Grooming: ${_traitsForBreedName(widget.breed.name).grooming}',
                      tone: _groomingTone(_traitsForBreedName(widget.breed.name).grooming),
                    ),
                    _TraitPill(
                      icon: Icons.straighten,
                      label: 'Size: ${_traitsForBreedName(widget.breed.name).size}',
                      tone: _sizeTone(_traitsForBreedName(widget.breed.name).size),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _traitsForBreedName(widget.breed.name).summary,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Photo'),
                ),
                ElevatedButton.icon(
                  onPressed: _saved ? null : _saveFavorite,
                  icon: Icon(_saved ? Icons.favorite : Icons.favorite_border),
                  label: const Text('Favorite'),
                ),
              ],
            ),
          ),
        ],
      ),
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
        color: tone.withOpacity(0.16),
        border: Border.all(color: tone.withOpacity(0.45)),
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
 
