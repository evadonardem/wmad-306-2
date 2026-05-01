import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/screens/breed_detail_screen.dart';
import 'package:adopt_a_dog/screens/favorites_screen.dart';
import 'package:adopt_a_dog/services/dog_api_service.dart';
import 'package:adopt_a_dog/services/search_service.dart';
import 'package:flutter/material.dart';

class BreedListScreen extends StatefulWidget {
  const BreedListScreen({super.key});

  @override
  State<BreedListScreen> createState() => _BreedListScreenState();
}

class _BreedListScreenState extends State<BreedListScreen> {
  late final Future<List<Breed>> _breedsFuture;
  final _service = DogApiService();
  final _searchService = SearchService();
  final _searchController = TextEditingController();
  
  String _searchTerm = '';
  String _filterType = 'all'; // 'all', 'with_sub', 'without_sub', 'favorites'
  String _sortType = 'az'; // 'az', 'za', 'sub_count'
  List<Breed> _allBreeds = [];
  List<Breed> _filteredBreeds = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _breedsFuture = _service.fetchBreeds();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchTerm = value;
      _applyFilters();
    });
  }

  void _setFilter(String filter) {
    setState(() {
      _filterType = filter;
      _applyFilters();
    });
  }

  void _setSort(String sort) {
    setState(() {
      _sortType = sort;
      _applyFilters();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchTerm = '';
      _searchController.clear();
      _applyFilters();
    });
  }

  Future<void> _applyFilters() async {
    if (!_isInitialized) return;

    List<Breed> result = List.from(_allBreeds);

    // Apply search filter
    if (_searchTerm.isNotEmpty) {
      result = _searchService.searchBreeds(result, _searchTerm);
    }

    // Apply breed type filter
    switch (_filterType) {
      case 'with_sub':
        result = _searchService.filterBreedsWithSubBreeds(result);
        break;
      case 'without_sub':
        result = _searchService.filterBreedsWithoutSubBreeds(result);
        break;
      case 'favorites':
        result = await _searchService.filterByFavorites(result);
        break;
      default:
        // 'all' - no additional filtering
        break;
    }

    // Apply sort
    switch (_sortType) {
      case 'za':
        result = _searchService.sortBreedsZA(result);
        break;
      case 'sub_count':
        result = _searchService.sortBreedsBySubBreedCount(result);
        break;
      default:
        result = _searchService.sortBreedsAZ(result);
        break;
    }

    setState(() {
      _filteredBreeds = result;
    });
  }

  Future<void> _initializeFilters(List<Breed> breeds) async {
    _allBreeds = breeds;
    _filteredBreeds = breeds;
    _isInitialized = true;
    await _applyFilters();
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
          // Search bar - Fixed at top with red background
          Container(
            color: Colors.red,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search breeds or sub-breeds...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      suffixIcon: _searchTerm.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: _clearSearch,
                              tooltip: 'Clear search',
                            )
                          : null,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    style: const TextStyle(color: Colors.black),
                    onChanged: _onSearchChanged,
                  ),
                ),
              ],
            ),
          ),
          
          // Filter chips
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All Breeds'),
                  selected: _filterType == 'all',
                  onSelected: (selected) => _setFilter('all'),
                  backgroundColor: Colors.white,
                ),
                FilterChip(
                  label: const Text('With Sub-breeds'),
                  selected: _filterType == 'with_sub',
                  onSelected: (selected) => _setFilter('with_sub'),
                  backgroundColor: Colors.white,
                ),
                FilterChip(
                  label: const Text('Without Sub-breeds'),
                  selected: _filterType == 'without_sub',
                  onSelected: (selected) => _setFilter('without_sub'),
                  backgroundColor: Colors.white,
                ),
                FilterChip(
                  label: const Text('My Favorites'),
                  selected: _filterType == 'favorites',
                  onSelected: (selected) => _setFilter('favorites'),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
          
          // Sort options
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Sort by:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortType,
                  items: const [
                    DropdownMenuItem(value: 'az', child: Text('A-Z')),
                    DropdownMenuItem(value: 'za', child: Text('Z-A')),
                    DropdownMenuItem(value: 'sub_count', child: Text('Sub-breeds')),
                  ],
                  onChanged: (value) => _setSort(value!),
                ),
                const Spacer(),
                Text(
                  _isInitialized 
                    ? '${_filteredBreeds.length} results' 
                    : 'Loading...',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Divider to separate filters from list
          const Divider(height: 1, thickness: 1),
          
          // List - Scrollable content below search bar
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
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // ③ Data ready
                if (!_isInitialized) {
                  _initializeFilters(snapshot.data!);
                }

                return ListView.builder(
                  itemCount: _filteredBreeds.length,
                  itemBuilder: (context, index) {
                    final breed = _filteredBreeds[index];
                    return ListTile(
                      leading: Icon(
                        breed.subBreeds.isNotEmpty ? Icons.category : Icons.pets,
                        color: breed.subBreeds.isNotEmpty ? Colors.blue : Colors.black,
                      ),
                      title: Text(
                        breed.name[0].toUpperCase() + breed.name.substring(1),
                      ),
                      subtitle: breed.subBreeds.isNotEmpty
                          ? Text('${breed.subBreeds.length} sub-breeds')
                          : null,
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
