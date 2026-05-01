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
  late final Future<List<Breed>> _breedsFuture;
  final _service = DogApiService();
  final _prefs = PrefsService();
  final _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _breedsFuture = _service.fetchBreeds();
    _loadLastSearch();
  }

  // Load last search term from shared_preferences
  Future<void> _loadLastSearch() async {
    final prefs = await _prefs.loadSearchTerm();
    if (prefs != null) {
      setState(() {
        _searchTerm = prefs;
        _searchController.text = prefs;
      });
    }
  }

  // Save search term to shared_preferences
  Future<void> _onSearchChanged(String value) async {
    setState(() => _searchTerm = value);
    await _prefs.saveSearchTerm(value);
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
        title: const Text("Choose a Breed"),
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search breeds...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchTerm != ''
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Breed List
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
                // Filter breeds based on search term
                final breeds = snapshot.data!
                    .where(
                      (b) => b.name.toLowerCase().contains(
                        _searchTerm.toLowerCase(),
                      ),
                    )
                    .toList();

                if (breeds.isEmpty) {
                  return const Center(child: Text('No breeds found.'));
                }

                return ListView.builder(
                  itemCount: breeds.length,
                  itemBuilder: (context, index) {
                    final breed = breeds[index];
                    return ListTile(
                      leading: const Icon(Icons.pets),
                      title: Text(
                        breed.name[0].toUpperCase() + breed.name.substring(1),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
