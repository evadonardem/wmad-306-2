// Deck Builder — current working deck, Save Deck dialog (Exercise 1),
// Start Battle CTA, link to Saved Decks.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/_neon.dart';

class DeckBuilderScreen extends StatelessWidget {
  const DeckBuilderScreen({super.key});

  Future<void> _saveDeck(BuildContext context, DeckProvider deck) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Save Deck', style: TextStyle(color: kNeonCyan)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Deck name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: kNeonCyan,
              foregroundColor: kBgDeep,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await deck.saveDeckToDb(name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: kSurface,
        content: Text(
          '“$name” saved to library',
          style: const TextStyle(color: kNeonCyan),
        ),
      ),
    );
  }

  void _startBattle(BuildContext context, DeckProvider deck) {
    if (!deck.isReady) return;
    final player = deck.deck.first;
    // Pick AI opponent: another hero in the deck if any, else the player.
    final ai = deck.deck.length > 1 ? deck.deck.last : player;
    context.read<BattleProvider>().startBattle(player, ai);
    Navigator.pushNamed(context, RouteNames.battle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Deck'),
        actions: [
          IconButton(
            tooltip: 'Saved Decks',
            icon: const Icon(Icons.bookmark, color: kNeonCyan),
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.savedDecks),
          ),
        ],
      ),
      body: Consumer<DeckProvider>(
        builder: (context, deck, _) {
          if (deck.deck.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.style, color: kNeonCyan, size: 64),
                    const SizedBox(height: 12),
                    Text(
                      'Your deck is empty',
                      style: kNeonTitle.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add up to 5 heroes from the roster.',
                      style: TextStyle(color: kTextDim),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${deck.deckSize} / ${DeckProvider.maxDeckSize}',
                  style: kNeonTitle.copyWith(fontSize: 18, color: kNeonCyan),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: deck.deck.length,
                  itemBuilder: (_, i) =>
                      _DeckRow(hero: deck.deck[i], deck: deck),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _saveDeck(context, deck),
                          icon: const Icon(Icons.save_alt),
                          label: const Text('Save Deck'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kNeonCyan),
                            foregroundColor: kNeonCyan,
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: deck.isReady
                              ? () => _startBattle(context, deck)
                              : null,
                          icon: const Icon(Icons.bolt),
                          label: const Text('Start Battle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNeonMagenta,
                            foregroundColor: kBgDeep,
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DeckRow extends StatelessWidget {
  final HeroModel hero;
  final DeckProvider deck;
  const _DeckRow({required this.hero, required this.deck});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: neonBorder(glow: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 48,
            height: 48,
            child: CachedNetworkImage(
              imageUrl: hero.imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) =>
                  const Icon(Icons.bolt, color: kNeonCyan),
            ),
          ),
        ),
        title: Text(hero.name, style: kNeonTitle.copyWith(fontSize: 14)),
        subtitle: Text(
          'HP ${hero.maxHp}  •  ATK ${hero.attack}  •  DEF ${hero.defense}',
          style: const TextStyle(color: kTextDim, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle, color: kNeonMagenta),
          onPressed: () => deck.removeHero(hero),
        ),
      ),
    );
  }
}
