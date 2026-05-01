import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/screens/breed_detail_screen.dart';
import 'package:adopt_a_dog/screens/favorites_screen.dart';
import 'package:adopt_a_dog/services/dog_api_service.dart';
import 'package:adopt_a_dog/services/prefs_service.dart';
import 'package:flutter/material.dart';

class BreedListScreen extends StatefulWidget {
  const BreedListScreen({super.key});

  @override
  State<BreedListScreen> createState() => _BreedListScreenState();
}

class _BreedListScreenState extends State<BreedListScreen> {
  final _prefsService = PrefsService();
  final _searchController = TextEditingController();
  late Future<void> _initializeFuture;
  final List<Breed> _allBreeds = [];
  final List<Breed> _filteredBreeds = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _initializeFuture = _initialize();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final lastSearch = await _prefsService.loadLastSearchTerm();
    if (lastSearch != null && lastSearch.isNotEmpty) {
      _searchTerm = lastSearch;
      _searchController.text = lastSearch;
    }

    final breeds = await DogApiService().fetchBreeds();
    _allBreeds.addAll(breeds);
    _applyFilter();
  }

  void _onSearchChanged() {
    final searchTerm = _searchController.text.trim();
    if (searchTerm == _searchTerm) {
      return;
    }

    _searchTerm = searchTerm;
    _prefsService.saveLastSearchTerm(_searchTerm);
    setState(_applyFilter);
  }

  void _applyFilter() {
    final normalizedSearch = _searchTerm.toLowerCase();
    _filteredBreeds
      ..clear()
      ..addAll(
        _allBreeds.where((breed) {
          if (breed.name.toLowerCase().contains(normalizedSearch)) {
            return true;
          }
          return breed.subBreeds.any(
            (subBreed) => subBreed.toLowerCase().contains(normalizedSearch),
          );
        }),
      );
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
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
            icon: const Icon(Icons.favorite),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search breeds',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: _filteredBreeds.isEmpty
                    ? Center(
                        child: Text(
                          _searchTerm.isEmpty
                              ? 'No breeds available.'
                              : 'No breeds match "$_searchTerm".',
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filteredBreeds.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final breed = _filteredBreeds[index];
                          return ListTile(
                            title: Text(breed.displayName()),
                            subtitle: breed.subBreeds.isNotEmpty
                                ? Text('${breed.subBreeds.length} sub-breed(s)')
                                : null,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BreedDetailScreen(breed: breed),
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
