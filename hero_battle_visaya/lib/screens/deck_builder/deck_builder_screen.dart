import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';
import 'saved_decks_screen.dart';

class DeckBuilderScreen extends StatelessWidget {
  const DeckBuilderScreen({super.key});

  String _slugify(String value) {
    final lower = value.toLowerCase();
    final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return replaced.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String _cdnHeroImageUrl(HeroModel hero) {
    final slug = _slugify(hero.name);
    if (hero.id.isEmpty || slug.isEmpty) return '';
    return 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/${hero.id}-$slug.jpg';
  }

  String _diceBearFallbackUrl(HeroModel hero) {
    final seed = hero.name.isNotEmpty ? hero.name : 'hero';
    return 'https://api.dicebear.com/9.x/bottts/avif?seed=${Uri.encodeComponent(seed)}';
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Widget _buildHeroAvatar({
    required HeroModel hero,
    required double radius,
  }) {
    final primaryUrl = _isValidUrl(hero.imageUrl) ? hero.imageUrl : '';
    final cdnUrl = _cdnHeroImageUrl(hero);

    Widget letterFallback() {
      return Center(
        child: Text(
          hero.name.isEmpty ? '?' : hero.name[0],
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: radius * 0.9,
          ),
        ),
      );
    }

    Widget diceBearFallback() {
      return Image.network(
        _diceBearFallbackUrl(hero),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => letterFallback(),
      );
    }

    Widget cdnFallback() {
      if (cdnUrl.isEmpty) return diceBearFallback();
      return Image.network(
        cdnUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => diceBearFallback(),
      );
    }

    final avatarImage = primaryUrl.isEmpty
        ? cdnFallback()
        : Image.network(
            primaryUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => cdnFallback(),
          );

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF4E3A79),
      child: ClipOval(
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: avatarImage,
        ),
      ),
    );
  }

  Widget _buildSectionPanel({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Future<void> _showSaveDialog(BuildContext context, DeckProvider deck) async {
    if (!deck.isReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one hero before saving.')),
      );
      return;
    }

    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Save Deck'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Deck name',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    final deckName = (name ?? '').trim();
    if (deckName.isEmpty) return;

    await deck.saveDeckToDb(deckName);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deck "$deckName" saved.')),
    );
  }

  Widget _buildHeroTile({
    required BuildContext context,
    required HeroModel hero,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: selected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5) : null,
          ),
          child: Row(
            children: [
              _buildHeroAvatar(hero: hero, radius: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(hero.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      'ATK ${hero.attack} • HP ${hero.maxHp}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.add_circle_outline,
                color: selected ? Theme.of(context).colorScheme.primary : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBattleTeamTile({
    required BuildContext context,
    required HeroModel hero,
    required VoidCallback onRemove,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        leading: _buildHeroAvatar(hero: hero, radius: 16),
        title: Text(hero.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('ATK ${hero.attack} • HP ${hero.maxHp}'),
        trailing: IconButton(
          tooltip: 'Remove from team',
          icon: const Icon(Icons.close),
          onPressed: onRemove,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_copy_outlined),
            tooltip: 'Saved Decks',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedDecksScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Quit',
            onPressed: () => Navigator.maybePop(context),
          ),
        ],
      ),
      body: Consumer<DeckProvider>(
        builder: (context, deck, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final selectionProgress = deck.battleTeamSize / DeckProvider.maxBattleTeamSize;

              final collectionSection = _buildSectionPanel(
                context: context,
                title: 'Collection: ${deck.deckSize}/${DeckProvider.maxDeckSize}',
                subtitle: 'Tap heroes to add or remove them from your battle team.',
                child: deck.deck.isEmpty
                    ? const Center(child: Text('No heroes in your collection yet.'))
                    : ListView.separated(
                        itemCount: deck.deck.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final hero = deck.deck[index];
                          final selected = deck.battleTeamContains(hero);
                          return _buildHeroTile(
                            context: context,
                            hero: hero,
                            selected: selected,
                            onTap: () => deck.toggleBattleHero(hero),
                          );
                        },
                      ),
              );

              final battleSection = _buildSectionPanel(
                context: context,
                title: 'Battle Team: ${deck.battleTeamSize}/${DeckProvider.maxBattleTeamSize}',
                subtitle: deck.isBattleTeamReady
                    ? 'Ready for deployment.'
                  : 'Choose ${DeckProvider.maxBattleTeamSize - deck.battleTeam.length} more hero(es).',
                child: deck.battleTeam.isEmpty
                    ? const SizedBox.expand()
                    : ListView.separated(
                        itemCount: deck.battleTeam.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final hero = deck.battleTeam[index];
                          return _buildBattleTeamTile(
                            context: context,
                            hero: hero,
                            onRemove: () => deck.removeFromBattleTeam(hero),
                          );
                        },
                      ),
              );

              final controls = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: deck.deck.length >= 5 ? deck.chooseRandomBattleTeam : null,
                    icon: const Icon(Icons.casino),
                    label: const Text('Choose Random Cards'),
                  ),
                  OutlinedButton.icon(
                    onPressed: deck.isReady ? deck.clearDeck : null,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear Deck'),
                  ),
                  FilledButton.icon(
                    onPressed: deck.isBattleTeamReady
                        ? () => Navigator.pushNamed(context, RouteNames.battle)
                        : null,
                    icon: const Icon(Icons.flag),
                    label: const Text('Deploy to Battle Arena'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showSaveDialog(context, deck),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Deck'),
                  ),
                ],
              );

              if (isWide) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Team Progress: ${deck.battleTeamSize}/${DeckProvider.maxBattleTeamSize}',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ),
                                  Text(
                                    deck.isBattleTeamReady ? 'Ready' : 'Building...',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: selectionProgress,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              const SizedBox(height: 12),
                              controls,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: collectionSection),
                            const SizedBox(width: 16),
                            Expanded(flex: 2, child: battleSection),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Team Progress: ${deck.battleTeamSize}/${DeckProvider.maxBattleTeamSize}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: selectionProgress,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            const SizedBox(height: 12),
                            controls,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: collectionSection),
                    const SizedBox(height: 16),
                    SizedBox(height: 220, child: battleSection),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
