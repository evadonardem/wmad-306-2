import 'package:flutter/material.dart';
import '../models/breed.dart';
import '../services/dog_api_service.dart';
import '../services/prefs_service.dart';
import 'breed_detail_screen.dart';
import 'favorites_screen.dart';
import 'adopted_screen.dart';

class BreedListScreen extends StatefulWidget {
  const BreedListScreen({super.key});

  @override
  State<BreedListScreen> createState() => _BreedListScreenState();
}

class _BreedListScreenState extends State<BreedListScreen> {
  late final Future<List<Breed>> _breedsFuture;
  final _service = DogApiService();
  final _prefs = PrefsService();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _breedsFuture = _service.fetchBreeds();
    _loadSearch();
  }

  void _loadSearch() async {
    _search = await _prefs.loadSearch();
    setState(() {});
  }

  void _updateSearch(String value) {
    setState(() => _search = value.toLowerCase());
    _prefs.saveSearch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Breed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.verified, color: Colors.blue), // Adopted list button
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdoptedScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.redAccent),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search breed...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _updateSearch,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Breed>>(
              future: _breedsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filtered = snapshot.data!
                    .where((b) => b.name.toLowerCase().contains(_search))
                    .toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final breed = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Card( // Elevated card design
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.pets, color: Colors.white, size: 20),
                          ),
                          title: Text(breed.name[0].toUpperCase() + breed.name.substring(1)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.blue),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BreedDetailScreen(breed: breed))),
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