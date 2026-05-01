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
  final TextEditingController _searchController = TextEditingController();
  List<Breed> _allBreeds = [];
  List<Breed> _filteredBreeds = [];

  @override
  void initState() {
    super.initState();
    _breedsFuture = _service.fetchBreeds();
    _loadLastSearch();
  }

  Future<void> _loadLastSearch() async {
    final prefs = await _prefs.loadLastSearch();
    if (prefs != null && prefs.isNotEmpty) {
      _searchController.text = prefs;
    }
  }

  void _filterBreeds(String query) {
    setState(() {
      _filteredBreeds = _allBreeds
          .where((b) => b.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    _prefs.saveLastSearch(query);
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
              MaterialPageRoute(
                builder: (_) => const FavoritesScreen(),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Breed>>(
        future: _breedsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Store breeds once
          if (_allBreeds.isEmpty) {
            _allBreeds = snapshot.data!;
            _filteredBreeds = _allBreeds
                .where((b) => b.name.toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterBreeds,
                  decoration: const InputDecoration(
                    hintText: 'Search breeds...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredBreeds.length,
                  itemBuilder: (context, index) {
                    final breed = _filteredBreeds[index];
                    return ListTile(
                      leading: const Icon(Icons.pets),
                      title: Text(breed.name.toUpperCase()[0] +
                          breed.name.substring(1)),
                      trailing: const Icon(Icons.chevron_right),
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