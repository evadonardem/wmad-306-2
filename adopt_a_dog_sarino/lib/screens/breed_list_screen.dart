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
  List<Breed> _allBreeds = [];
  List<Breed> _filteredBreeds = [];
  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _breedsFuture = _service.fetchBreeds();
    _loadSearchTerm();
  }

  Future<void> _loadSearchTerm() async {
    final savedSearch = await _prefs.loadSearchTerm();
    if (savedSearch != null) {
      setState(() {
        _searchTerm = savedSearch;
        _searchController.text = savedSearch;
      });
    }
  }

  void _filterBreeds(String query) {
    setState(() {
      _searchTerm = query.toLowerCase();
      _filteredBreeds = _allBreeds
          .where((breed) => breed.name.toLowerCase().contains(_searchTerm))
          .toList();
    });
    _prefs.saveSearchTerm(_searchTerm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Choose a Breed", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
            icon: const Icon(Icons.favorite, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background for the search bar area
          Container(
            height: 120, // Height for app bar + search bar
            color: Colors.white,
          ),
          // Content
          Column(
            children: [
              // Search bar with background
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search breeds...',
                    prefixIcon: Icon(Icons.search, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onChanged: _filterBreeds,
                ),
              ),
              // List view
              Expanded(
                child: FutureBuilder<List<Breed>>(
                  future: _breedsFuture,
                  builder: (context, snapshot) {
                    // ① Still waiting
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // ② Error
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.blue)));
                    }

                    // ③ Data ready
                    if (_allBreeds.isEmpty) {
                      _allBreeds = snapshot.data!;
                      _filteredBreeds = _allBreeds;
                      if (_searchTerm.isNotEmpty) {
                        _filterBreeds(_searchTerm);
                      }
                    }

                    return ListView.builder(
                      itemCount: _filteredBreeds.length,
                      itemBuilder: (context, index) {
                        final breed = _filteredBreeds[index];
                        return ListTile(
                          leading: const Icon(Icons.pets, color: Colors.blue),
                          title: Text(
                            breed.name.toUpperCase()[0] + breed.name.substring(1),
                            style: const TextStyle(color: Colors.blue),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.blue),
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
        ],
      ),
    );
  }
}
