import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';
import '../../services/database_service.dart';

class SavedDecksScreen extends StatefulWidget {
  const SavedDecksScreen({super.key});

  @override
  State<SavedDecksScreen> createState() => _SavedDecksScreenState();
}

class _SavedDecksScreenState extends State<SavedDecksScreen> {
  late Future<List<Map<String, dynamic>>> _savedDecksFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _savedDecksFuture = DatabaseService().loadDecks();
  }

  Future<void> _deleteDeck(int id) async {
    await DatabaseService().deleteDeck(id);
    if (!mounted) {
      return;
    }
    setState(_reload);
  }

  String _formatCreated(String? iso) {
    if (iso == null || iso.isEmpty) {
      return 'Unknown date';
    }

    final parsed = DateTime.tryParse(iso);
    if (parsed == null) {
      return iso;
    }

    final local = parsed.toLocal();
    final mm = local.month.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$mm-$dd $hh:$min';
  }

  Future<void> _showDeckDetails(
    String name,
    String created,
    List<HeroModel> heroes,
  ) async {
    final mediaQuery = MediaQuery.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.85,
      ),
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(name, style: Theme.of(context).textTheme.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text('$created - ${heroes.length} heroes'),
            ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: FilledButton.icon(
                    onPressed: heroes.isEmpty
                        ? null
                        : () {
                            context.read<DeckProvider>().replaceDeck(heroes);
                            context.read<BattleProvider>().reset(notify: false);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Saved deck loaded for battle'),
                                duration: Duration(milliseconds: 1200),
                              ),
                            );
                            Navigator.pushNamed(this.context, RouteNames.battle);
                          },
                    icon: const Icon(Icons.sports_martial_arts),
                    label: const Text('Battle This Saved Deck'),
                  ),
                ),
            const Divider(height: 1),
            Expanded(
              child: heroes.isEmpty
                  ? const Center(child: Text('No heroes in this deck.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: heroes.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final hero = heroes[index];
                        return Card(
                          child: ListTile(
                            title: Text(hero.name),
                            subtitle: Text(
                              '${hero.publisher} • HP ${hero.maxHp} • ATK ${hero.attack}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                this.context,
                                RouteNames.heroDetail,
                                arguments: <String, dynamic>{
                                  'hero': hero,
                                  'alreadyInDeck': true,
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Decks')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _savedDecksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? <Map<String, dynamic>>[];
          if (data.isEmpty) {
            return const Center(child: Text('No saved decks yet.'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final row = data[index];
              final heroes = DatabaseService().parseDeckHeroes(row);
              final deckName = row['name'] as String? ?? 'Unnamed Deck';
              final createdRaw = row['created'] as String?;
              final created = _formatCreated(createdRaw);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  onTap: () => _showDeckDetails(deckName, created, heroes),
                  title: Text(deckName),
                  subtitle: Text('${heroes.length} heroes • $created'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteDeck(row['id'] as int),
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
