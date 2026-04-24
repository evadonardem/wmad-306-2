import 'package:flutter/material.dart';

import '../models/breed.dart';
import '../services/dog_api_service.dart';

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

_BreedTraits _traitsForBreed(Breed breed) {
  final name = breed.name.toLowerCase();
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

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final _api = DogApiService();
  late final Future<List<Breed>> _breedsFuture;

  Breed? _breedA;
  Breed? _breedB;

  // Image futures — refreshed when a breed is chosen
  Future<String>? _imgA;
  Future<String>? _imgB;

  @override
  void initState() {
    super.initState();
    _breedsFuture = _api.fetchBreeds();
  }

  void _selectBreed(Breed breed, {required bool isA}) {
    setState(() {
      if (isA) {
        _breedA = breed;
        _imgA = _api.fetchRandomImage(breed.name);
      } else {
        _breedB = breed;
        _imgB = _api.fetchRandomImage(breed.name);
      }
    });
  }

  void _refreshImage({required bool isA}) {
    setState(() {
      if (isA && _breedA != null) {
        _imgA = _api.fetchRandomImage(_breedA!.name);
      } else if (!isA && _breedB != null) {
        _imgB = _api.fetchRandomImage(_breedB!.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare Dogs')),
      body: FutureBuilder<List<Breed>>(
        future: _breedsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final breeds = snapshot.data!;

          return Column(
            children: [
              // ── Breed selectors ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: _BreedPicker(
                        label: 'Dog A',
                        breeds: breeds,
                        selected: _breedA,
                        onSelected: (b) => _selectBreed(b, isA: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BreedPicker(
                        label: 'Dog B',
                        breeds: breeds,
                        selected: _breedB,
                        onSelected: (b) => _selectBreed(b, isA: false),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ── Side-by-side comparison ───────────────────────────────
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _BreedColumn(
                        breed: _breedA,
                        imageFuture: _imgA,
                        onRefresh: () => _refreshImage(isA: true),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: _BreedColumn(
                        breed: _breedB,
                        imageFuture: _imgB,
                        onRefresh: () => _refreshImage(isA: false),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Breed autocomplete picker ─────────────────────────────────────────────────

class _BreedPicker extends StatefulWidget {
  const _BreedPicker({
    required this.label,
    required this.breeds,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<Breed> breeds;
  final Breed? selected;
  final ValueChanged<Breed> onSelected;

  @override
  State<_BreedPicker> createState() => _BreedPickerState();
}

class _BreedPickerState extends State<_BreedPicker> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Breed>(
      displayStringForOption: (b) => _capitalise(b.name),
      optionsBuilder: (textEditingValue) {
        final q = textEditingValue.text.toLowerCase();
        if (q.isEmpty) return widget.breeds;
        return widget.breeds
            .where((b) => b.name.toLowerCase().contains(q));
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: 'Type to search…',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            isDense: true,
            suffixIcon: widget.selected != null
                ? const Icon(Icons.check_circle, color: Colors.teal)
                : null,
          ),
        );
      },
      onSelected: widget.onSelected,
    );
  }
}

// ── Single breed column ───────────────────────────────────────────────────────

class _BreedColumn extends StatelessWidget {
  const _BreedColumn({
    required this.breed,
    required this.imageFuture,
    required this.onRefresh,
  });

  final Breed? breed;
  final Future<String>? imageFuture;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (breed == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'Pick a breed above',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final traits = _traitsForBreed(breed!);

    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
          gradient: LinearGradient(
            colors: [cs.surface, cs.surfaceContainerLowest],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              // ── Image ──────────────────────────────────────────────────
              Expanded(
                child: FutureBuilder<String>(
                  future: imageFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(
                          child: Icon(Icons.broken_image, size: 48));
                    }
                    return Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (ctx, err, st) =>
                          const Center(child: Icon(Icons.broken_image, size: 48)),
                    );
                  },
                ),
              ),

              // ── Info panel ─────────────────────────────────────────────
              Container(
                width: double.infinity,
                color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capitalise(breed!.name),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        breed!.subBreeds.isNotEmpty
                            ? '${breed!.subBreeds.length} sub-breed${breed!.subBreeds.length == 1 ? '' : 's'}'
                            : 'No sub-breeds',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _TraitPill(
                          icon: Icons.directions_run,
                          label: 'Lifestyle',
                          value: traits.lifestyle,
                          tone: _lifestyleTone(context, traits.lifestyle),
                        ),
                        _TraitPill(
                          icon: Icons.brush,
                          label: 'Grooming',
                          value: traits.grooming,
                          tone: _groomingTone(context, traits.grooming),
                        ),
                        _TraitPill(
                          icon: Icons.straighten,
                          label: 'Size',
                          value: traits.size,
                          tone: _sizeTone(context, traits.size),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Text(
                        traits.summary,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: onRefresh,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('New photo'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
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
    );
  }
}

class _TraitPill extends StatelessWidget {
  const _TraitPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
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
            '$label: $value',
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

Color _lifestyleTone(BuildContext context, String value) {
  final v = value.toLowerCase();
  if (v.contains('very')) return Colors.deepOrange;
  if (v.contains('relaxed')) return Colors.blueGrey;
  if (v.contains('moderate')) return Colors.indigo;
  return Theme.of(context).colorScheme.primary;
}

Color _groomingTone(BuildContext context, String value) {
  final v = value.toLowerCase();
  if (v.contains('high')) return Colors.purple;
  if (v.contains('medium')) return Colors.amber.shade800;
  return Colors.green.shade700;
}

Color _sizeTone(BuildContext context, String value) {
  final v = value.toLowerCase();
  if (v.contains('large')) return Colors.brown;
  if (v.contains('small')) return Colors.teal;
  return Colors.blue;
}

String _capitalise(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
