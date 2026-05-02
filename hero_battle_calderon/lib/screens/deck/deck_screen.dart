import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_selection_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/battle_provider.dart';
import '../../engine/battle_engine.dart';
import '../../router/app_router.dart';
import '../../widgets/hero_image.dart';
import '../../widgets/hero_card.dart';

class DeckScreen extends StatelessWidget {
  const DeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.style_rounded),
            SizedBox(width: 8),
            Text('Decks', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Consumer<DeckProvider>(
        builder: (context, deckProvider, child) {
          if (deckProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeDecks = deckProvider.savedDecks.where((d) => d != null).toList();
          final showCreateButton = activeDecks.length < DeckProvider.totalDecksCount;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Text('Sort by:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => deckProvider.toggleSortOrder(),
                      icon: Icon(
                        deckProvider.isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                      visualDensity: VisualDensity.compact,
                      tooltip: deckProvider.isAscending ? 'Ascending' : 'Descending',
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: DeckSortBy.values.map((criteria) {
                            final isSelected = deckProvider.sortBy == criteria;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(_formatSortLabel(criteria), style: const TextStyle(fontSize: 11)),
                                selected: isSelected,
                                onSelected: (_) => deckProvider.setSortBy(criteria),
                                visualDensity: VisualDensity.compact,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeDecks.length + (showCreateButton ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < activeDecks.length) {
                      final deck = activeDecks[index]!;
                      // Find actual index in original provider list for deletion
                      final originalIndex = deckProvider.savedDecks.indexOf(deck);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AspectRatio(
                          aspectRatio: 4 / 1,
                          child: _buildActiveDeck(context, originalIndex, deck),
                        ),
                      );
                    } else {
                      return Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 4 / 1,
                            child: _buildEmptyDeck(context, deckProvider.firstEmptyIndex),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${activeDecks.length} / ${DeckProvider.totalDecksCount} Decks',
                            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatSortLabel(DeckSortBy criteria) {
    String name = criteria.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  Widget _buildEmptyDeck(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _showHeroSelection(context, index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.5), width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.withValues(alpha: 0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'Create new Deck',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDeck(BuildContext context, int index, DeckModel deck) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'DECK',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    deck.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Tooltip(
                    message: 'To Battle',
                    preferBelow: false,
                    verticalOffset: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton.filled(
                        onPressed: () => _startDeckBattle(context, deck),
                        icon: const Icon(Icons.play_arrow_rounded, size: 28),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: deck.heroes.map((hero) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AspectRatio(
                        aspectRatio: 0.7,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            HeroImage(
                              urls: [hero.imageUrl, hero.akababImageUrl],
                              heroId: hero.id,
                              heroName: hero.name,
                              searchTerms: hero.aliases,
                              fit: BoxFit.cover,
                              loading: Container(color: Colors.grey[300]),
                              error: const Icon(Icons.error, size: 10),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                color: Colors.black54,
                                child: Text(
                                  hero.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_note, color: Colors.blue),
                  onPressed: () => _showRenameDialog(context, deck),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => context.read<DeckProvider>().deleteDeckAt(index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, DeckModel deck) async {
    final nameController = TextEditingController(text: deck.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Deck'),
        content: TextField(controller: nameController, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, nameController.text), child: const Text('Save')),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && deck.id != null) {
      if (context.mounted) {
        await context.read<DeckProvider>().renameDeck(deck.id!, newName);
      }
    }
  }

  void _startDeckBattle(BuildContext context, DeckModel deck) async {
    final String aiName = BattleEngine.getRandomAiName();
    final searchProvider = context.read<HeroSearchProvider>();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      // Get 4 random heroes for the AI
      List<HeroModel> aiHeroes = [];
      for (int i = 0; i < 4; i++) {
        aiHeroes.add(await searchProvider.getRandomHero());
      }
      
      if (context.mounted) Navigator.pop(context); // Close loading dialog
      
      if (context.mounted) {
        _showTeamBattleDialog(context, deck.heroes, aiHeroes, aiName);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Battle error: $e')));
      }
    }
  }

  void _showTeamBattleDialog(BuildContext context, List<HeroModel> playerTeam, List<HeroModel> aiTeam, String aiName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Center(
          child: Text(
            'BATTLE PREVIEW',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTeamPreview(context, Provider.of<PlayerProvider>(context, listen: false).playerName.toUpperCase(), playerTeam, Colors.blue),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Divider(color: Colors.white24),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.red,
                    child: Text('VS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
            ),
            _buildTeamPreview(context, aiName.toUpperCase(), aiTeam, Colors.red),
          ],
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                RouteNames.battle,
                arguments: {
                  'playerTeam': playerTeam,
                  'aiTeam': aiTeam,
                  'aiName': aiName,
                },
              );
            }, 
            child: const Text('TO BATTLE!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamPreview(BuildContext context, String label, List<HeroModel> team, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: team.map((hero) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: color.withOpacity(0.5), width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: HeroImage(
                    urls: [hero.imageUrl, hero.akababImageUrl],
                    heroId: hero.id,
                    heroName: hero.name,
                    searchTerms: hero.aliases,
                    fit: BoxFit.cover,
                    loading: Container(color: Colors.grey[800]),
                    error: const Icon(Icons.person, size: 20, color: Colors.white24),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showHeroSelection(BuildContext context, int deckIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HeroSelectionPopover(deckIndex: deckIndex),
    );
  }
}

class HeroSelectionPopover extends StatefulWidget {
  final int deckIndex;
  const HeroSelectionPopover({super.key, required this.deckIndex});

  @override
  State<HeroSelectionPopover> createState() => _HeroSelectionPopoverState();
}

class _HeroSelectionPopoverState extends State<HeroSelectionPopover> {
  final List<HeroModel> _selectedHeroes = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeroSelectionProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<HeroSelectionProvider>().search(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildSelectedRow(),
              Expanded(child: _buildHeroGrid(scrollController)),
              _buildFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Select up to 4 Heroes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search superheroes...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: _searchController.text.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<HeroSelectionProvider>().search('');
                },
              )
            : const Icon(Icons.search_off, color: Colors.grey),
        ),
        onChanged: _onSearchChanged,
        onSubmitted: (value) {
          _debounce?.cancel();
          context.read<HeroSelectionProvider>().search(value);
        },
      ),
    );
  }

  Widget _buildSelectedRow() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Text('Selected: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedHeroes.length,
              itemBuilder: (context, index) {
                    final hero = _selectedHeroes[index];
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 60,
                              height: 80,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  HeroImage(
                                    urls: [hero.imageUrl, hero.akababImageUrl],
                                    heroId: hero.id,
                                    heroName: hero.name,
                                    searchTerms: hero.aliases,
                                    fit: BoxFit.cover,
                                    loading: Container(color: Colors.grey),
                                    error: const Icon(Icons.error),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      color: Colors.black54,
                                      child: Text(
                                        hero.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedHeroes.removeAt(index)),
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroGrid(ScrollController scrollController) {
    return Consumer<HeroSelectionProvider>(
      builder: (context, selectionProvider, child) {
        if (selectionProvider.isLoading) return const Center(child: CircularProgressIndicator());
        
        final results = selectionProvider.results;
        
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No results for "${selectionProvider.currentQuery}"',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final hero = results[index];
            final isSelected = _selectedHeroes.any((h) => h.id == hero.id);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedHeroes.removeWhere((h) => h.id == hero.id);
                  } else if (_selectedHeroes.length < 4) {
                    _selectedHeroes.add(hero);
                  }
                });
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: HeroImage(
                      urls: [hero.imageUrl, hero.akababImageUrl],
                      heroId: hero.id,
                      heroName: hero.name,
                      searchTerms: hero.aliases,
                      fit: BoxFit.cover,
                      loading: Container(color: Colors.grey[200]),
                      error: const Icon(Icons.error),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      color: Colors.black54,
                      child: Text(hero.name, style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue, width: 3),
                      ),
                      child: const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 40)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _selectedHeroes.isEmpty ? null : _saveDeck,
        child: Text('Save Deck (${_selectedHeroes.length}/4)'),
      ),
    );
  }

  void _saveDeck() async {
    final nameController = TextEditingController(text: 'New Deck ${widget.deckIndex + 1}');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Name your Deck'),
        content: TextField(controller: nameController, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, nameController.text), child: const Text('Save')),
        ],
      ),
    );

    if (name != null && name.isNotEmpty && mounted) {
      await context.read<DeckProvider>().createOrUpdateDeck(widget.deckIndex, name, _selectedHeroes);
      if (mounted) Navigator.pop(context);
    }
  }
}
