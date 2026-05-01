import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/breed.dart';
import '../services/dog_api_service.dart';
import '../services/prefs_service.dart';

class BreedDetailScreen extends StatefulWidget {
  final Breed breed;
  const BreedDetailScreen({super.key, required this.breed});

  @override
  State<BreedDetailScreen> createState() => _BreedDetailScreenState();
}

class _BreedDetailScreenState extends State<BreedDetailScreen> {
  late Future<String> _imageFuture;
  final _api = DogApiService();
  final _prefs = PrefsService();

  @override
  void initState() {
    super.initState();
    _imageFuture = _api.fetchRandomImage(widget.breed.name);
  }

  Future<void> _adopt() async {
    final list = await _prefs.loadAdopted();
    if (!list.contains(widget.breed.name)) {
      list.add(widget.breed.name);
      await _prefs.saveAdopted(list); // Saves to adopted list
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dog Adopted! Check your list.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.breed.name.toUpperCase()),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () async {
              final list = await _prefs.loadFavorites();
              if (!list.contains(widget.breed.name)) {
                list.add(widget.breed.name);
                await _prefs.saveFavorites(list);
              }
            },
          )
        ],
      ),
      body: FutureBuilder<String>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: snapshot.data!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text("About the ${widget.breed.name}: This friendly pup is looking for a home!", textAlign: TextAlign.center),
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent, // Blue design
        onPressed: _adopt,
        label: const Text("ADOPT ME", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.pets, color: Colors.white),
      ),
    );
  }
}