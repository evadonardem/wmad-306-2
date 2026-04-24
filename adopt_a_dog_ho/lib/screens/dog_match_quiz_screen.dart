import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/screens/breed_detail_screen.dart';
import 'package:flutter/material.dart';

import '../services/dog_api_service.dart';
import '../services/prefs_service.dart';
import '../widgets/dog_image_viewer.dart';
import 'package:flutter/services.dart';

enum LifestylePreference { active, relaxed }

enum SizePreference { small, medium, large }

enum GroomingPreference { low, medium, high }

class DogMatchQuizScreen extends StatefulWidget {
  const DogMatchQuizScreen({super.key});

  @override
  State<DogMatchQuizScreen> createState() => _DogMatchQuizScreenState();
}

class _DogMatchQuizScreenState extends State<DogMatchQuizScreen> {
  final _api = DogApiService();

  late final Future<List<Breed>> _breedsFuture;
  LifestylePreference? _lifestyle;
  SizePreference? _size;
  GroomingPreference? _grooming;
  bool _isFindingMatch = false;

  Breed? _match;
  Future<String>? _matchImageFuture;
  String? _matchReason;
  final GlobalKey _resultKey = GlobalKey();
  final _prefs = PrefsService();
  bool _matchSaved = false;

  @override
  void initState() {
    super.initState();
    _breedsFuture = _api.fetchBreeds();
  }

  Future<void> _findMatch(List<Breed> breeds) async {
    if (_lifestyle == null || _size == null || _grooming == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all three questions.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isFindingMatch = true;
      _match = null;
      _matchImageFuture = null;
      _matchReason = null;
    });

    final candidates = _buildCandidateNames(
      lifestyle: _lifestyle!,
      size: _size!,
      grooming: _grooming!,
    );

    Breed? matchedBreed;
    for (final candidate in candidates) {
      for (final breed in breeds) {
        if (breed.name == candidate) {
          matchedBreed = breed;
          break;
        }
      }
      if (matchedBreed != null) {
        break;
      }
    }

    matchedBreed ??= breeds.firstWhere(
      (breed) => breed.name == 'hound',
      orElse: () => breeds.first,
    );

    try {
      final imageUrl = await _api.fetchRandomImage(matchedBreed.name);

      if (!mounted) {
        return;
      }

      setState(() {
        _match = matchedBreed;
        _matchReason = _buildReason(
          lifestyle: _lifestyle!,
          size: _size!,
          grooming: _grooming!,
          breedName: matchedBreed!.name,
        );
        _matchImageFuture = Future.value(imageUrl);
        _isFindingMatch = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _resultKey.currentContext;
        if (ctx != null) {
          try {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              alignment: 0.1,
            );
          } catch (_) {}
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isFindingMatch = false;
      });
      rethrow;
    }
  }

  List<String> _buildCandidateNames({
    required LifestylePreference lifestyle,
    required SizePreference size,
    required GroomingPreference grooming,
  }) {
    if (lifestyle == LifestylePreference.active &&
        size == SizePreference.small &&
        grooming == GroomingPreference.low) {
      return ['basenji', 'terrier', 'beagle'];
    }

    if (lifestyle == LifestylePreference.active &&
        size == SizePreference.small &&
        grooming != GroomingPreference.low) {
      return ['pomeranian', 'terrier', 'chihuahua'];
    }

    if (lifestyle == LifestylePreference.active &&
        size == SizePreference.medium &&
        grooming == GroomingPreference.low) {
      return ['kelpie', 'collie', 'beagle'];
    }

    if (lifestyle == LifestylePreference.active &&
        size == SizePreference.medium &&
        grooming == GroomingPreference.medium) {
      return ['border', 'australian', 'spaniel'];
    }

    if (lifestyle == LifestylePreference.active &&
        size == SizePreference.medium &&
        grooming == GroomingPreference.high) {
      return ['sheepdog', 'spaniel', 'setter'];
    }

    if (lifestyle == LifestylePreference.active &&
        size == SizePreference.large &&
        grooming == GroomingPreference.low) {
      return ['malinois', 'ridgeback', 'doberman'];
    }

    if (lifestyle == LifestylePreference.active &&
        size == SizePreference.large &&
        grooming != GroomingPreference.low) {
      return ['retriever', 'shepherd', 'husky'];
    }

    if (lifestyle == LifestylePreference.relaxed &&
        size == SizePreference.small &&
        grooming == GroomingPreference.low) {
      return ['pug', 'frise', 'shihtzu'];
    }

    if (lifestyle == LifestylePreference.relaxed &&
        size == SizePreference.small &&
        grooming == GroomingPreference.medium) {
      return ['shihtzu', 'papillon', 'pekinese'];
    }

    if (lifestyle == LifestylePreference.relaxed &&
        size == SizePreference.small &&
        grooming == GroomingPreference.high) {
      return ['maltese', 'poodle', 'pomeranian'];
    }

    if (lifestyle == LifestylePreference.relaxed &&
        size == SizePreference.medium &&
        grooming == GroomingPreference.low) {
      return ['bulldog', 'basset', 'boxer'];
    }

    if (lifestyle == LifestylePreference.relaxed &&
        size == SizePreference.medium &&
        grooming == GroomingPreference.medium) {
      return ['spaniel', 'whippet', 'saluki'];
    }

    if (lifestyle == LifestylePreference.relaxed &&
        size == SizePreference.medium &&
        grooming == GroomingPreference.high) {
      return ['poodle', 'sheepdog', 'setter'];
    }

    if (lifestyle == LifestylePreference.relaxed &&
        size == SizePreference.large &&
        grooming == GroomingPreference.low) {
      return ['mastiff', 'danish', 'hound'];
    }

    if (lifestyle == LifestylePreference.relaxed &&
        size == SizePreference.large &&
        grooming == GroomingPreference.medium) {
      return ['retriever', 'newfoundland', 'bernese'];
    }

    return ['sheepdog', 'retriever', 'setter'];
  }

  String _buildReason({
    required LifestylePreference lifestyle,
    required SizePreference size,
    required GroomingPreference grooming,
    required String breedName,
  }) {
    final lifestyleText = lifestyle == LifestylePreference.active
        ? 'active'
        : 'relaxed';
    final sizeText = switch (size) {
      SizePreference.small => 'small',
      SizePreference.medium => 'medium',
      SizePreference.large => 'large',
    };
    final groomingText = switch (grooming) {
      GroomingPreference.low => 'lower-maintenance',
      GroomingPreference.medium => 'moderate-maintenance',
      GroomingPreference.high => 'higher-maintenance',
    };

    return '${_capitalise(breedName)} fits a $lifestyleText lifestyle, '
        'matches your preference for a $sizeText dog, and suits a '
        '$groomingText grooming routine.';
  }

  void _resetQuiz() {
    setState(() {
      _match = null;
      _matchImageFuture = null;
      _matchReason = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dog Match Quiz')),
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Answer these 3 quick questions and I will suggest a breed.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              // Progress indicator for the quiz
              Builder(builder: (context) {
                final answered = (_lifestyle != null ? 1 : 0) +
                    (_size != null ? 1 : 0) +
                    (_grooming != null ? 1 : 0);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: answered / 3),
                    const SizedBox(height: 6),
                    Text('$answered of 3 answered',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                );
              }),
              const SizedBox(height: 20),
              _QuestionCard<LifestylePreference>(
                title: 'Active or relaxed lifestyle?',
                value: _lifestyle,
                options: const {
                  LifestylePreference.active: 'Active',
                  LifestylePreference.relaxed: 'Relaxed',
                },
                onChanged: (value) => setState(() => _lifestyle = value),
              ),
              const SizedBox(height: 12),
              _QuestionCard<SizePreference>(
                title: 'Wants small, medium, or large dog?',
                value: _size,
                options: const {
                  SizePreference.small: 'Small',
                  SizePreference.medium: 'Medium',
                  SizePreference.large: 'Large',
                },
                onChanged: (value) => setState(() => _size = value),
              ),
              const SizedBox(height: 12),
              _QuestionCard<GroomingPreference>(
                title: 'Grooming level?',
                value: _grooming,
                options: const {
                  GroomingPreference.low: 'Low',
                  GroomingPreference.medium: 'Medium',
                  GroomingPreference.high: 'High',
                },
                onChanged: (value) => setState(() => _grooming = value),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _isFindingMatch ? null : () => _findMatch(breeds),
                icon: _isFindingMatch
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isFindingMatch ? 'Finding your match...' : 'Find My Match',
                ),
              ),
              if (_match != null && _matchImageFuture != null) ...[
                const SizedBox(height: 24),
                Card(
                  key: _resultKey,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: _matchImageFuture,
                        builder: (context, imageSnapshot) {
                          if (imageSnapshot.connectionState !=
                              ConnectionState.done) {
                            return const SizedBox(
                              height: 220,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (imageSnapshot.hasError) {
                            return const SizedBox(
                              height: 220,
                              child: Center(
                                child: Icon(Icons.broken_image, size: 64),
                              ),
                            );
                          }

                          return Hero(
                            tag: 'hero-match-${_match!.name}',
                            child: DogImageViewer(
                              imageUrl: imageSnapshot.data!,
                              height: 220,
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Match: ${_capitalise(_match!.name)}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(_matchReason ?? ''),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                FilledButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BreedDetailScreen(breed: _match!),
                                    ),
                                  ),
                                  child: const Text('View Breed'),
                                ),
                                const SizedBox(width: 12),
                                FilledButton.icon(
                                  onPressed: _matchSaved
                                      ? null
                                      : () async {
                                          final messenger =
                                              ScaffoldMessenger.of(context);
                                          await _prefs.saveFavorite(_match!.name);
                                          if (!mounted) return;
                                          setState(() => _matchSaved = true);
                                          messenger.showSnackBar(SnackBar(
                                            content: Text(
                                                '${_capitalise(_match!.name)} saved!'),
                                            duration: const Duration(seconds: 2),
                                          ));
                                        },
                                  icon: Icon(
                                      _matchSaved ? Icons.favorite : Icons.favorite_border),
                                  label: const Text('Save'),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () async {
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final msg =
                                        'My dog match is ${_capitalise(_match!.name)} — ${_matchReason ?? ''}';
                                    await Clipboard.setData(
                                        ClipboardData(text: msg));
                                    if (!mounted) return;
                                    messenger.showSnackBar(const SnackBar(
                                      content: Text('Match copied to clipboard'),
                                      duration: Duration(seconds: 2),
                                    ));
                                  },
                                  icon: const Icon(Icons.share),
                                  label: const Text('Share'),
                                ),
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: _resetQuiz,
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _QuestionCard<T> extends StatelessWidget {
  const _QuestionCard({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final T? value;
  final Map<T, String> options;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: RadioGroup<T>(
          groupValue: value,
          onChanged: onChanged,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...options.entries.map(
                (entry) => RadioListTile<T>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.value),
                  value: entry.key,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _capitalise(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
