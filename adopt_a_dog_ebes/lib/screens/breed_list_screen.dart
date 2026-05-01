import 'package:flutter/material.dart';
import '../models/breed.dart';
import '../services/dog_api_service.dart';
import '../services/prefs_service.dart';
import 'breed_detail_screen.dart';
import 'favorites_screen.dart';

class BreedListScreen extends StatefulWidget {
  const BreedListScreen({super.key});

  @override
  State<BreedListScreen> createState() => _BreedListScreenState();
}

class _BreedListScreenState extends State<BreedListScreen> {
  // Store the Future once so rebuilds don't re-fetch.
  late final Future<List<Breed>> _breedsFuture;
  final _service = DogApiService();
  final _prefs = PrefsService();

  // Exercise 4 — Search & Filter
  final TextEditingController _searchController = TextEditingController();
  List<Breed> _allBreeds = [];
  List<Breed> _filteredBreeds = [];
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _breedsFuture = _service.fetchBreeds();

    // Exercise 4 — pre-fill search bar with last saved term
    _prefs.loadLastSearch().then((term) {
      if (term.isNotEmpty) {
        _searchController.text = term;
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Exercise 4 — filter client-side, no extra API calls
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    _prefs.saveLastSearch(_searchController.text); // persist last term
    setState(() {
      _filteredBreeds = query.isEmpty
          ? List.from(_allBreeds)
          : _allBreeds
              .where((b) => b.name.toLowerCase().contains(query))
              .toList();
    });
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Breed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'My Favorites',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Breed>>(
        future: _breedsFuture,
        builder: (context, snapshot) {
          // ① Still waiting
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // ② Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // ③ Data ready — initialise lists on first build
          if (!_dataLoaded) {
            _allBreeds = snapshot.data!;
            final query = _searchController.text.toLowerCase().trim();
            _filteredBreeds = query.isEmpty
                ? List.from(_allBreeds)
                : _allBreeds
                    .where((b) => b.name.toLowerCase().contains(query))
                    .toList();
            _dataLoaded = true;
          }

          return Column(
            children: [
              // Exercise 4 — Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search breeds…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _prefs.saveLastSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              // Breed list
              Expanded(
                child: _filteredBreeds.isEmpty
                    ? const Center(child: Text('No breeds match your search.'))
                    : ListView.builder(
                        itemCount: _filteredBreeds.length,
                        itemBuilder: (context, index) {
                          final breed = _filteredBreeds[index];
                          return ListTile(
                            leading: const Icon(Icons.pets),
                            title: Text(_capitalize(breed.name)),
                            subtitle: breed.subBreeds.isNotEmpty
                                ? Text(
                                    breed.subBreeds
                                        .map(_capitalize)
                                        .join(', '),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  )
                                : null,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BreedDetailScreen(breed: breed),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
