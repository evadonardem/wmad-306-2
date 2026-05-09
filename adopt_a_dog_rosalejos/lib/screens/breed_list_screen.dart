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
  final _apiService = DogApiService();
  final _prefsService = PrefsService();

  final _searchController = TextEditingController();
  List<Breed> _allBreeds = [];
  List<Breed> _filteredBreeds = [];
  bool _isDataInitialized = false;

  @override
  void initState() {
    super.initState();
    _breedsFuture = _apiService.fetchBreeds();
    _loadLastSearch();
  }

  Future<void> _loadLastSearch() async {
    final lastSearch = await _prefsService.loadSearchTerm();
    if (mounted) {
      setState(() {
        _searchController.text = lastSearch;
      });
    }
  }

  void _filterBreeds(String query) {
    setState(() {
      _filteredBreeds = _allBreeds
          .where((breed) =>
              breed.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    _prefsService.saveSearchTerm(query);
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
        leading: const Icon(Icons.pets, color: Colors.white),
        title: const Text('Choose a Breed'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.pets, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FavoritesScreen(),
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.favorite),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search breeds...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterBreeds('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterBreeds,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Breed>>(
              future: _breedsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return _buildSkeletonLoader();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!_isDataInitialized) {
                  _allBreeds = snapshot.data!;
                  _filteredBreeds = _allBreeds
                      .where((breed) => breed.name
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase()))
                      .toList();
                  _isDataInitialized = true;
                }

                if (_filteredBreeds.isEmpty) {
                  return const Center(child: Text('No breeds found.'));
                }

                return ListView.builder(
                  itemCount: _filteredBreeds.length,
                  itemBuilder: (context, index) {
                    final breed = _filteredBreeds[index];
                    final isEven = index % 2 == 0;
                    
                    final bgColor = isEven ? const Color(0xFF424874) : const Color(0xFFA6B1E1);
                    final contentColor = isEven ? const Color(0xFFDCD6F7) : const Color(0xFFF4EEFF);

                    return Container(
                      color: bgColor,
                      child: ListTile(
                        leading: Icon(Icons.pets, color: contentColor),
                        title: Text(
                          breed.name.toUpperCase()[0] + breed.name.substring(1),
                          style: TextStyle(
                            color: contentColor, 
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        trailing: Icon(Icons.chevron_right, color: contentColor),
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

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        final isEven = index % 2 == 0;
        final bgColor = isEven ? const Color(0xFF424874).withAlpha(179) : const Color(0xFFA6B1E1).withAlpha(179);
        final contentColor = isEven ? const Color(0xFFDCD6F7).withAlpha(128) : const Color(0xFFF4EEFF).withAlpha(128);

        return Container(
          color: bgColor,
          child: ListTile(
            leading: Icon(Icons.pets, color: contentColor),
            title: Container(
              height: 16,
              width: 100,
              decoration: BoxDecoration(
                color: contentColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: contentColor),
          ),
        );
      },
    );
  }
}
