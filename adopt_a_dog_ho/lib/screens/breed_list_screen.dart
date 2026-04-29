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
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _breedsFuture = _service.fetchBreeds();
    _prefs.loadLastSearch().then((value) {
      if (value != null && value.isNotEmpty) {
        setState(() {
          _searchTerm = value;
          _searchController.text = value;
        });
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search breeds...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value.trim();
                });
                _prefs.saveLastSearch(_searchTerm);
              },
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

                final breeds = snapshot.data!;
                final filteredBreeds = _searchTerm.isEmpty
                    ? breeds
                    : breeds
                        .where((breed) => breed.name
                            .toLowerCase()
                            .contains(_searchTerm.toLowerCase()))
                        .toList();

                if (filteredBreeds.isEmpty) {
                  return const Center(child: Text('No breeds found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filteredBreeds.length,
                  itemBuilder: (context, index) {
                    final breed = filteredBreeds[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.pets_outlined),
                        title: Text(
                          breed.name[0].toUpperCase() + breed.name.substring(1),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BreedDetailScreen(breed: breed),
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
