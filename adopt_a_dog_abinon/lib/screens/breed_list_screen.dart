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

  final _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _breedsFuture = _service.fetchBreeds();

    _prefs.loadLastSearchTerm().then((value) {
      if (value != null && value.isNotEmpty) {
        _searchTerm = value;
        _searchController.text = value;
        setState(() {});
      }
    });

    _searchController.addListener(() {
      final term = _searchController.text.trim().toLowerCase();
      if (term != _searchTerm) {
        setState(() => _searchTerm = term);
        _prefs.saveLastSearchTerm(term);
      }
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
      body: FutureBuilder<List<Breed>>(
        future: _breedsFuture,
        builder: (context, snapshot) {
          // 1. Still waiting
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 3. Data ready
          final breeds = snapshot.data!;
          final filteredBreeds = _searchTerm.isEmpty
              ? breeds
              : breeds
                    .where(
                      (breed) => breed.name.toLowerCase().contains(
                        _searchTerm.toLowerCase(),
                      ),
                    )
                    .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search breeds',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: filteredBreeds.isEmpty
                    ? const Center(child: Text('No breeds match your search.'))
                    : ListView.builder(
                        itemCount: filteredBreeds.length,
                        itemBuilder: (context, index) {
                          final breed = filteredBreeds[index];

                          return ListTile(
                            leading: const Icon(Icons.pets),
                            title: Text(
                              breed.name[0].toUpperCase() +
                                  breed.name.substring(1),
                            ),
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
