import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../router/app_router.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hero_card.dart';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  final _deckNameController = TextEditingController();
  final _api = SuperheroApiService();
  late final Future<List<HeroModel>> _heroesFuture;
  HeroRarity? _selectedRarityFilter;

  @override
  void initState() {
    super.initState();
    _heroesFuture = _api.fetchRandomHeroes(count: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('DECK BUILDER'),
        backgroundColor: const Color(0xDD0F0F17),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            color: const Color(0xFF121212),
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'save',
                child: const Text('Save Current Deck'),
              ),
              PopupMenuItem(
                value: 'saved',
                child: const Text('View Saved Decks'),
              ),
            ],
            onSelected: (value) {
              if (value == 'save') {
                final deck = context.read<DeckProvider>();
                if (deck.deck.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add heroes first before saving a deck'),
                    ),
                  );
                  return;
                }
                _showSaveDeckDialog(deck);
              } else if (value == 'saved') {
                Navigator.pushNamed(context, RouteNames.savedDecks);
              }
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF121212),
      body: Consumer<DeckProvider>(
        builder: (context, deck, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              children: [
                _buildDeckHeader(deck),
                const SizedBox(height: 16),
                _buildActionRow(deck),
                const SizedBox(height: 16),
                _buildFilterRow(),
                const SizedBox(height: 12),
                Expanded(child: _buildAvailableHeroes(deck)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeckHeader(DeckProvider deck) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT DECK',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${deck.deckSize}/${DeckProvider.maxDeckSize} heroes selected',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              if (deck.deck.isEmpty)
                const Text(
                  'Pick five heroes and dominate the arena.',
                  style: TextStyle(color: Colors.white60),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final hero in deck.deck)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hero.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  context.read<DeckProvider>().removeHero(hero),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF3B3BFF),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(DeckProvider deck) {
    return Row(
      children: [
        Expanded(
          child: _glassButton(
            label: 'BATTLE',
            icon: Icons.sports_kabaddi,
            enabled: deck.isReady,
            onPressed: () => Navigator.pushNamed(context, RouteNames.battle),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _glassButton(
            label: 'RECENT',
            icon: Icons.history,
            enabled: true,
            onPressed: () => Navigator.pushNamed(context, RouteNames.history),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildFilterChipRow(
              label: 'All',
              selected: _selectedRarityFilter == null,
              onTap: () => setState(() => _selectedRarityFilter = null),
            ),
            for (final rarity in HeroRarity.values)
              _buildFilterChipRow(
                label: rarity.name.toUpperCase(),
                selected: _selectedRarityFilter == rarity,
                rarity: rarity,
                onTap: () => setState(() => _selectedRarityFilter = rarity),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailableHeroes(DeckProvider deck) {
    return Consumer<HeroSearchProvider>(
      builder: (context, searchProvider, _) {
        final heroes = searchProvider.searchResults;
        if (heroes.isNotEmpty) {
          return _buildHeroGrid(heroes, deck);
        }

        return FutureBuilder<List<HeroModel>>(
          future: _heroesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading heroes: ${snapshot.error}'),
              );
            }
            final heroList = snapshot.data ?? [];
            if (heroList.isEmpty) {
              return const Center(
                child: Text('No available heroes to display'),
              );
            }
            final filtered = _selectedRarityFilter == null
                ? heroList
                : heroList.where((hero) => hero.rarity == _selectedRarityFilter).toList();
            return _buildHeroGrid(filtered, deck);
          },
        );
      },
    );
  }

  Widget _buildHeroGrid(List<HeroModel> heroes, DeckProvider deck) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
      itemCount: heroes.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
      ),
      itemBuilder: (context, index) {
        final hero = heroes[index];
        final inDeck = deck.contains(hero);
        return HeroCard(
          hero: hero,
          showDeckAction: true,
          isInDeck: inDeck,
          onAction: () {
            if (inDeck) {
              deck.removeHero(hero);
            } else {
              deck.addHero(hero);
            }
          },
        );
      },
    );
  }

  Widget _buildFilterChipRow({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    HeroRarity? rarity,
  }) {
    final Color baseColor;
    switch (rarity) {
      case HeroRarity.legendary:
        baseColor = const Color(0xFFFFD700);
        break;
      case HeroRarity.epic:
        baseColor = const Color(0xFF7B2FBE);
        break;
      case HeroRarity.rare:
        baseColor = const Color(0xFF3A8FFF);
        break;
      case HeroRarity.common:
      case null:
        baseColor = Colors.white38;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? baseColor.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color: selected ? baseColor.withValues(alpha: 0.75) : Colors.white12,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _glassButton({
    required String label,
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: enabled
            ? const Color(0xFF7A3BFF)
            : const Color(0xFF2A2A2A),
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 18),
        elevation: 4,
      ),
    );
  }


  void _showSaveDeckDialog(DeckProvider deck) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Deck'),
          content: TextField(
            controller: _deckNameController,
            decoration: const InputDecoration(
              labelText: 'Deck Name',
              hintText: 'My Legendary Team',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _deckNameController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _deckNameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a deck name.')),
                  );
                  return;
                }
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                await deck.saveDeckToDb(name);
                if (!mounted) return;
                _deckNameController.clear();
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Saved deck "$name"')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _deckNameController.dispose();
    super.dispose();
  }
}
