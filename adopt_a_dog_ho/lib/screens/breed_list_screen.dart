import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/screens/breed_detail_screen.dart';
import 'package:adopt_a_dog/screens/compare_screen.dart';
import 'package:adopt_a_dog/screens/dog_match_quiz_screen.dart';
import 'package:adopt_a_dog/screens/favorites_screen.dart';
import 'package:flutter/material.dart';

import '../services/dog_api_service.dart';
import '../services/prefs_service.dart';

class BreedListScreen extends StatefulWidget {
  const BreedListScreen({super.key});

  @override
  State<BreedListScreen> createState() => _BreedListScreenState();
}

class _BreedListScreenState extends State<BreedListScreen> {
  // API future stored once so rebuilds don't re-fetch
  late final Future<List<Breed>> _breedsFuture;
  final _service = DogApiService();
  final _prefs = PrefsService();

  // Ex4: search state
  final _searchController = TextEditingController();
  List<Breed> _allBreeds = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _breedsFuture = _service.fetchBreeds();
    _restoreSearchQuery();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Ex4: pre-fill search bar from persisted query
  Future<void> _restoreSearchQuery() async {
    final saved = await _prefs.loadSearchQuery();
    if (saved.isNotEmpty && mounted) {
      setState(() {
        _query = saved;
        _searchController.text = saved;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
    _prefs.saveSearchQuery(value); // fire-and-forget persistence
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  // Ex4: client-side filter — no extra API calls
  List<Breed> get _displayedBreeds {
    if (_query.isEmpty) return _allBreeds;
    final lower = _query.toLowerCase();
    return _allBreeds
        .where((b) => b.name.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Breed'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompareScreen()),
            ),
            icon: const Icon(Icons.compare),
            tooltip: 'Compare Dogs',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DogMatchQuizScreen()),
            ),
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Dog Match Quiz',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
            icon: const Icon(Icons.favorite),
          ),
        ],
      ),
      body: Column(
        children: [
          // Ex4: search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search breeds…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                isDense: true,
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Breed>>(
              future: _breedsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Cache the full list once loaded
                _allBreeds = snapshot.data!;
                final displayed = _displayedBreeds;

                if (displayed.isEmpty) {
                  return const Center(child: Text('No breeds found.'));
                }

                return ListView.builder(
                  itemCount: displayed.length,
                  itemBuilder: (context, index) {
                    final breed = displayed[index];
                    return ListTile(
                      leading: const Icon(Icons.pets),
                      title: Text(_capitalise(breed.name)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BreedDetailScreen(breed: breed),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _capitalise(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
