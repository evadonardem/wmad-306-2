import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';
import '../../services/database_service.dart';
import '../../widgets/hp_bar.dart';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});
  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder',
            style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.style_rounded), text: 'My Deck'),
            Tab(icon: Icon(Icons.save_rounded), text: 'Saved Decks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _CurrentDeckTab(),
          _SavedDecksTab(),
        ],
      ),
    );
  }
}

// ── Tab 1: Current deck ───────────────────────────────────────────────────

class _CurrentDeckTab extends StatelessWidget {
  const _CurrentDeckTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<DeckProvider>(
      builder: (context, deck, _) {
        return Column(
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Text(
                    '${deck.deckSize} / ${DeckProvider.maxDeckSize} heroes',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  if (deck.isReady) ...[
                    // Save deck
                    TextButton.icon(
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Save'),
                      onPressed: () => _showSaveDialog(context, deck),
                    ),
                    // Clear deck
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error),
                      onPressed: () => _confirmClear(context, deck),
                    ),
                  ],
                ],
              ),
            ),

            // Capacity bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: HpBar(
                current: deck.deckSize,
                max: DeckProvider.maxDeckSize,
                height: 8,
                showLabel: false,
              ),
            ),

            // Hero list
            Expanded(
              child: deck.deck.isEmpty
                  ? _EmptyDeck()
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: deck.deck.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) =>
                          _HeroListTile(hero: deck.deck[i], deck: deck),
                    ),
            ),

            // Battle button
            if (deck.isReady)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.bolt),
                    label: const Text('Start Battle!'),
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteNames.battle),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Exercise 1 — save deck dialog ─────────────────────────────────────
  void _showSaveDialog(BuildContext context, DeckProvider deck) {
    final controller = TextEditingController(
        text: 'Deck ${DateTime.now().day}/${DateTime.now().month}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Deck'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Deck name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await deck.saveDeckToDb(name);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deck "$name" saved!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, DeckProvider deck) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Deck?'),
        content: const Text('This will remove all heroes from your current deck.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              deck.clearDeck();
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _HeroListTile extends StatelessWidget {
  final HeroModel hero;
  final DeckProvider deck;
  const _HeroListTile({required this.hero, required this.deck});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            hero.imageUrl,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 52,
              height: 52,
              color: cs.surfaceVariant,
              child: const Icon(Icons.person),
            ),
          ),
        ),
        title: Text(hero.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '⚔️ ATK ${hero.attack}  🛡️ DEF ${hero.defense}  ❤️ HP ${hero.maxHp}',
            style: const TextStyle(fontSize: 11)),
        trailing: IconButton(
          icon: Icon(Icons.remove_circle_outline,
              color: cs.error),
          onPressed: () {
            deck.removeHero(hero);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('${hero.name} removed'),
                  duration: const Duration(seconds: 1)),
            );
          },
        ),
        onTap: () => Navigator.pushNamed(context, RouteNames.heroDetail,
            arguments: hero),
      ),
    );
  }
}

class _EmptyDeck extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.style_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 14),
            Text('Your deck is empty',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text('Browse the Hero Roster to add up to 5 heroes',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Browse Heroes'),
              onPressed: () => Navigator.pushNamed(context, RouteNames.home),
            ),
          ],
        ),
      );
}

// ── Tab 2: Saved decks (Exercise 1) ──────────────────────────────────────

class _SavedDecksTab extends StatefulWidget {
  const _SavedDecksTab();
  @override
  State<_SavedDecksTab> createState() => _SavedDecksTabState();
}

class _SavedDecksTabState extends State<_SavedDecksTab> {
  late Future<List<Map<String, dynamic>>> _decksFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() =>
      setState(() => _decksFuture = DatabaseService().loadDecks());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _decksFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snap.data ?? [];
        if (rows.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.save_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 14),
                Text('No saved decks yet',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                const Text('Build a deck and tap Save',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: rows.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _SavedDeckCard(
            row: rows[i],
            onDeleted: _reload,
          ),
        );
      },
    );
  }
}

class _SavedDeckCard extends StatelessWidget {
  final Map<String, dynamic> row;
  final VoidCallback onDeleted;
  const _SavedDeckCard({required this.row, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> rawHeroes = jsonDecode(row['heroes'] as String);
    final heroes =
        rawHeroes.map((e) => HeroModel.fromJson(e as Map<String, dynamic>)).toList();
    final created = DateTime.tryParse(row['created'] as String);
    final dateStr = created != null
        ? '${created.day}/${created.month}/${created.year}'
        : '';

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.style_rounded),
        title: Text(row['name'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${heroes.length} heroes  •  $dateStr',
            style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Load into current deck
            IconButton(
              icon: const Icon(Icons.upload_rounded),
              tooltip: 'Load into current deck',
              onPressed: () => _loadDeck(context, heroes),
            ),
            // Delete
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              tooltip: 'Delete',
              onPressed: () => _deleteDeck(context, row['id'] as int),
            ),
          ],
        ),
        children: heroes
            .map((h) => ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundImage:
                        h.imageUrl.isNotEmpty ? NetworkImage(h.imageUrl) : null,
                    child: h.imageUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(h.name),
                  subtitle: Text(
                      '⚔️${h.attack}  🛡️${h.defense}  ❤️${h.maxHp}',
                      style: const TextStyle(fontSize: 11)),
                ))
            .toList(),
      ),
    );
  }

  void _loadDeck(BuildContext context, List<HeroModel> heroes) {
    final deck = context.read<DeckProvider>();
    deck.clearDeck();
    for (final h in heroes.take(DeckProvider.maxDeckSize)) {
      deck.addHero(h);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Loaded "${row['name']}" into current deck')),
    );
  }

  Future<void> _deleteDeck(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Deck?'),
        content: Text('Delete "${row['name']}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseService().deleteDeck(id);
      onDeleted();
    }
  }
}
