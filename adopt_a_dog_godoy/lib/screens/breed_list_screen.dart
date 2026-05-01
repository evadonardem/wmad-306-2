import 'package:adopt_a_dog/models/breed.dart';
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
  final _dogApiService = DogApiService();

  late Future<List<Breed>> _breedsFuture;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _breedsFuture = _dogApiService.fetchBreeds();
    _loadLastSearchTerm();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final newTerm = _searchController.text.trim();
    if (newTerm == _searchTerm) return;
    setState(() {
      _searchTerm = newTerm;
    });
    _prefsService.saveLastSearchTerm(_searchTerm);
  }

  Future<void> _loadLastSearchTerm() async {
    final term = await _prefsService.loadLastSearchTerm();
    if (term != null && term.isNotEmpty) {
      _searchController.text = term;
      setState(() {
        _searchTerm = term;
      });
    }
  }

  List<Breed> _filterBreeds(List<Breed> breeds) {
    if (_searchTerm.isEmpty) {
      return breeds;
    }
    final lower = _searchTerm.toLowerCase();
    return breeds
        .where((breed) => breed.name.toLowerCase().contains(lower))
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
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
            icon: const Icon(Icons.favorite),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search breeds',
                border: const OutlineInputBorder(),
                suffixIcon: _searchTerm.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _prefsService.saveLastSearchTerm('');
                        },
                      )
                    : null,
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
                  return const Center(child: Text('Failed to load breeds.'));
                }

                final breeds = _filterBreeds(snapshot.data ?? []);
                if (breeds.isEmpty) {
                  return const Center(child: Text('No breeds match your search.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: breeds.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final breed = breeds[index];
                    return ListTile(
                      title: Text(breed.name),
                      subtitle: breed.subBreeds.isNotEmpty
                          ? Text('${breed.subBreeds.length} sub-breed(s)')
                          : null,
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
