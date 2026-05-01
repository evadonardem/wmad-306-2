import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/screens/breed_detail_screen.dart';
import 'package:adopt_a_dog/screens/favorites_screen.dart';
import 'package:adopt_a_dog/services/dog_api_service.dart';
import 'package:flutter/material.dart';

class BreedListScreen extends StatefulWidget {
  const BreedListScreen({super.key});

  @override
  State<BreedListScreen> createState() => _BreedListScreenState();
}

class _BreedListScreenState extends State<BreedListScreen> {
  late final Future<List<Breed>> _breedsFuture;
  final _api = DogApiService();

  @override
  void initState() {
    super.initState();
    _breedsFuture = _api.fetchBreeds();
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
            tooltip: 'View favorite breed',
          ),
        ],
      ),
      body: FutureBuilder<List<Breed>>(
        future: _breedsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load breeds: ${snapshot.error}'),
            );
          }

          final breeds = snapshot.data ?? [];

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: breeds.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final breed = breeds[index];
              final displayName = breed.name[0].toUpperCase() + breed.name.substring(1);

              return _StaggeredBreedTile(
                index: index,
                child: ListTile(
                  tileColor: Colors.green.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Text(displayName[0]),
                  ),
                  title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Subbreeds: ${breed.subBreeds.length}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 700),
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.92, end: 1).animate(
                              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                            ),
                            child: BreedDetailScreen(breed: breed),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StaggeredBreedTile extends StatefulWidget {
  final Widget child;
  final int index;
  const _StaggeredBreedTile({required this.child, required this.index});

  @override
  State<_StaggeredBreedTile> createState() => _StaggeredBreedTileState();
}

class _StaggeredBreedTileState extends State<_StaggeredBreedTile> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 480),
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 480),
        offset: _visible ? Offset.zero : const Offset(-0.18, 0),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
