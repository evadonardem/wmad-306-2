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
  late final Future<List<Breed>> _breedsFuture;
  final _service = DogApiService();
  final _prefs = PrefsService();

  final _searchController = TextEditingController();
  List<Breed> _allBreeds = [];
  List<Breed> _filteredBreeds = [];

  @override
  void initState() {
    super.initState();
    _breedsFuture = _service.fetchBreeds();
    _initSearch();
  }

  Future<void> _initSearch() async {
    final lastSearch = await _prefs.loadLastSearch();
    _searchController.text = lastSearch;
    _searchController.addListener(_onSearchChanged);
    if (_allBreeds.isNotEmpty) {
      _onSearchChanged();
    }
  }

  void _onSearchChanged() {
    final term = _searchController.text.toLowerCase();
    _prefs.saveLastSearch(term);
    setState(() {
      _filteredBreeds = _allBreeds
          .where((b) => b.name.toLowerCase().contains(term))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Breed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Breeds',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Breed>>(
              future: _breedsFuture,
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
                            'Loading breeds...',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (_allBreeds.isEmpty) {
                  _allBreeds = snapshot.data!;
                  final term = _searchController.text.toLowerCase();
                  _filteredBreeds = _allBreeds
                      .where((b) => b.name.toLowerCase().contains(term))
                      .toList();
                }

                return ListView.builder(
                  itemCount: _filteredBreeds.length,
                  itemBuilder: (context, index) {
                    final breed = _filteredBreeds[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 1.5,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: index % 2 == 0
                              ? const Color(0xFF95E1D3)
                              : const Color(0xFFFCE38A),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.pets),
                          title: Text(
                            breed.name.toUpperCase()[0] +
                                breed.name.substring(1),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BreedDetailScreen(breed: breed),
                            ),
                          ),
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
