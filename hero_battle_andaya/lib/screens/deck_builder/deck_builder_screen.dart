import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../services/database_service.dart';
import '../../services/superhero_api_service.dart';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({Key? key}) : super(key: key);

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  HeroModel? _selectedPlayerHero;
  HeroModel? _selectedOpponentHero;
  bool _isBattling = false;
  final _apiService = SuperheroApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        centerTitle: true,
        actions: [
          Consumer<DeckProvider>(
            builder: (context, deckProvider, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () => _showLoadDialog(context, deckProvider),
                    tooltip: 'Load deck',
                  ),
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: deckProvider.isReady ? () => _showSaveDialog(context, deckProvider) : null,
                    tooltip: 'Save deck',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Consumer<DeckProvider>(
          builder: (context, deckProvider, child) {
            // Auto-select first hero if none selected and deck has heroes
            if (_selectedPlayerHero == null && deckProvider.deck.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _selectedPlayerHero = deckProvider.deck.first;
                });
              });
            }
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        'Deck Size: ${deckProvider.deckSize}/${DeckProvider.maxDeckSize}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (deckProvider.deckSize > 0)
                        TextButton(
                          onPressed: () => deckProvider.clearDeck(),
                          child: const Text('Clear Squad'),
                        ),
                    ],
                  ),
                ),
                
                // Deck heroes section
                if (deckProvider.deck.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Your Squad Heroes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: deckProvider.deck.length,
                      itemBuilder: (context, index) {
                        final hero = deckProvider.deck[index];
                        final isSelected = _selectedPlayerHero?.id == hero.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPlayerHero = hero;
                            });
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey,
                                width: isSelected ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    hero.name.isNotEmpty ? hero.name[0] : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hero.name,
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Battle section
                Card(
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Battle',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        
                        
                        // Opponent selection
                        if (_selectedPlayerHero != null) ...[
                          FutureBuilder<List<HeroModel>>(
                            future: _apiService.fetchRandomHeroes(count: 5),
                            builder: (context, snapshot) {
                              // Auto-select first opponent if none selected and opponents are loaded
                              if (snapshot.hasData && 
                                  _selectedOpponentHero == null && 
                                  (snapshot.data ?? []).isNotEmpty) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  setState(() {
                                    _selectedOpponentHero = snapshot.data!.first;
                                  });
                                });
                              }
                              
                              return Column(
                                children: [
                          const Text(
                            'Select Opponent',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (snapshot.connectionState != ConnectionState.done)
                            const Center(child: CircularProgressIndicator())
                          else if (snapshot.hasError)
                            Text('Error loading opponents: ${snapshot.error}')
                          else
                            _buildOpponentList(snapshot.data ?? []),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Selected heroes display
                        if (_selectedPlayerHero != null && _selectedOpponentHero != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _HeroCard(hero: _selectedPlayerHero!, isPlayer: true),
                              const Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              _HeroCard(hero: _selectedOpponentHero!, isPlayer: false),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Battle button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_selectedPlayerHero == null || _selectedOpponentHero == null || _isBattling) 
                                ? null 
                                : _startBattle,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: _isBattling
                                ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Battling...'),
                                    ],
                                  )
                                : const Text('Start Battle'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Deck list section
                if (deckProvider.deck.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Text(
                            'Your squad is empty. Add heroes to build your squad!',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/hero-search');
                            },
                            child: const Text('Search Heroes'),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Squad Management',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: deckProvider.deck.length,
                    itemBuilder: (context, index) {
                      final hero = deckProvider.deck[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              hero.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 50),
                            ),
                          ),
                          title: Text(hero.name),
                          subtitle: Text(hero.publisher),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => deckProvider.removeHero(hero),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _startBattle() async {
    if (_selectedPlayerHero == null || _selectedOpponentHero == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both heroes for battle!')),
      );
      return;
    }

    setState(() {
      _isBattling = true;
    });

    // Start battle using BattleProvider (always computer opponent)
    context.read<BattleProvider>().startBattle(
      _selectedPlayerHero!, 
      _selectedOpponentHero!,
      isComputerOpponent: true,
    );
    
    // Navigate to battle screen
    Navigator.pushNamed(context, '/battle');
  }

  
  void _showSaveDialog(BuildContext context, DeckProvider deckProvider) {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Squad'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Squad Name',
            hintText: 'Enter a name for your squad',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                try {
                  await deckProvider.saveDeckToDb(name);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Squad "$name" saved successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save squad: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentList(List<HeroModel> opponents) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: opponents.length,
        itemBuilder: (context, index) {
          final hero = opponents[index];
          final isSelected = _selectedOpponentHero?.id == hero.id;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedOpponentHero = hero;
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.red : Colors.grey,
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.red,
                    child: Text(
                      hero.name.isNotEmpty ? hero.name[0] : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hero.name,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLoadDialog(BuildContext context, DeckProvider deckProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Squad'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseService().getAllDecks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final decks = snapshot.data ?? [];
              if (decks.isEmpty) {
                return const Center(child: Text('No saved squads found.'));
              }
              return ListView.builder(
                itemCount: decks.length,
                itemBuilder: (context, index) {
                  final deck = decks[index];
                  return ListTile(
                    title: Text(deck['name']),
                    subtitle: Text('Heroes: ${deck['heroes'].toString().length > 50 ? '...' : deck['heroes']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try {
                          await deckProvider.deleteDeckFromDb(deck['id']);
                          Navigator.of(context).pop();
                          _showLoadDialog(context, deckProvider); // Refresh the dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Squad deleted successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete squad: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    onTap: () async {
                      try {
                        await deckProvider.loadDeckFromDb(deck['name']);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Squad "${deck['name']}" loaded successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to load deck: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final HeroModel hero;
  final bool isPlayer;

  const _HeroCard({
    Key? key,
    required this.hero,
    required this.isPlayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: isPlayer ? Colors.blue : Colors.red,
              child: Text(
                hero.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hero.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Power: ${hero.powerStats.power}'),
            Text('Speed: ${hero.powerStats.speed}'),
            Text('Defense: ${hero.defense}'),
          ],
        ),
      ),
    );
  }
}
