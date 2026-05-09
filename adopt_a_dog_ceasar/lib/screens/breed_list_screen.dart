import 'package:adopt_a_dog/screens/favorites_screen.dart';
import 'package:adopt_a_dog/screens/breed_detail_screen.dart';
import 'package:adopt_a_dog/services/dog_api_service.dart';
import 'package:adopt_a_dog/models/breed.dart';
import 'package:flutter/material.dart';

class BreedListScreen extends StatefulWidget {
  const BreedListScreen({super.key});

  @override
  State<BreedListScreen> createState() => _BreedListScreenState();
}

class _BreedListScreenState extends State<BreedListScreen> {
  late Future<List<Breed>> _breedsFuture;
  
  final List<Color> _pastelColors = [
    const Color(0xFFFFB3BA), // Pink
    const Color(0xFFFFDFBA), // Orange
    const Color(0xFFFFFFBA), // Yellow
    const Color(0xFFBAFFC9), // Green
    const Color(0xFFBAE1FF), // Blue
  ];

  @override
  void initState() {
    super.initState();
    _breedsFuture = DogApiService().fetchBreeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5), // Light cute background
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Adopt a Dog",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFFF85A2), // Cute vibrant pink header
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
            icon: const Icon(Icons.favorite, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Breed>>(
        future: _breedsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF85A2)),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No breeds found.'));
          }

          final breeds = snapshot.data!;
          final flattenedBreeds = <Map<String, dynamic>>[];
          for (var breed in breeds) {
            if (breed.subBreeds.isEmpty) {
              flattenedBreeds.add({'breed': breed, 'subBreed': null});
            } else {
              for (var sub in breed.subBreeds) {
                flattenedBreeds.add({'breed': breed, 'subBreed': sub});
              }
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: flattenedBreeds.length,
            itemBuilder: (context, index) {
              final item = flattenedBreeds[index];
              final breed = item['breed'] as Breed;
              final subBreed = item['subBreed'] as String?;
              final displayName = breed.displayName(sub: subBreed);
              final title = displayName.split(' ').map((word) {
                if (word.isEmpty) return word;
                return word[0].toUpperCase() + word.substring(1);
              }).join(' ');

              final color = _pastelColors[index % _pastelColors.length];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: color,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white54,
                    child: Icon(Icons.pets, color: Colors.black54),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BreedDetailScreen(
                          breed: breed,
                          subBreed: subBreed,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
