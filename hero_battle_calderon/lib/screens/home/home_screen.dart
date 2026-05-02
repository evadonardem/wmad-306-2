import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../widgets/hero_card.dart';
import '../main/main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeroSearchProvider>().fetchRandom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: Colors.amber),
            SizedBox(width: 8),
            Text('HERO BATTLE', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          MainScreen.of(context)?.setIndex(1); // Index 1 is the Deck Tab
        },
        label: const Text('PLAY'),
        icon: const Icon(Icons.play_arrow_rounded),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<HeroSearchProvider>(
        builder: (context, searchProvider, child) {
          if (searchProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (searchProvider.error.isNotEmpty) {
            return Center(child: Text('Error: ${searchProvider.error}'));
          }
          final results = searchProvider.randomResults;
          if (results.isEmpty) {
            return const Center(child: Text('No heroes found.'));
          }
          return RefreshIndicator(
            onRefresh: () => searchProvider.fetchRandom(),
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final hero = results[index];
                return HeroCard(hero: hero);
              },
            ),
          );
        },
      ),
    );
  }
}
