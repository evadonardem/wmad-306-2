import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  static const String _openDrawerArg = 'openDrawer';
  static const String _fromDrawerArg = 'fromDrawer';

  void _goBack() {
    final args = ModalRoute.of(context)?.settings.arguments;
    final openedFromDrawer =
        args is Map<String, dynamic> && args[_fromDrawerArg] == true;
    if (openedFromDrawer) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteNames.home,
        (_) => false,
        arguments: <String, dynamic>{_openDrawerArg: true},
      );
      return;
    }

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushReplacementNamed(
      RouteNames.home,
      arguments: <String, dynamic>{_openDrawerArg: true},
    );
  }

  Future<void> _promptSaveDeck(DeckProvider deck) async {
    final controller = TextEditingController(text: 'My Deck');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1C2A),
        title: const Text('Save Deck', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Deck name',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withValues(alpha:0.2)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF7B2FBE)),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true && controller.text.trim().isNotEmpty) {
        try {
          await deck.saveDeckToDb(controller.text.trim());
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deck Saved'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          if (!mounted) {
            return;
          }
          final message = e.toString().contains(
                'same name and heroes already exists',
              )
              ? 'This deck is already saved.'
              : 'Could not save deck. Please try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: _goBack,
        ),
        title: const Text('Deck Builder'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF12101D), Color(0xFF1F1D35)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    _buildDeckHeader(deck, theme),
                    const SizedBox(height: 24),
                    _buildDeckContent(deck, theme),
                  ],
                ),
              ),
              _buildDeckActions(deck, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeckHeader(DeckProvider deck, ThemeData theme) {
    final fillPercentage = (deck.deckSize / DeckProvider.maxDeckSize * 100).toStringAsFixed(0);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha:0.15),
            theme.colorScheme.secondary.withValues(alpha:0.08),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha:0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha:0.4),
                      theme.colorScheme.primary.withValues(alpha:0.2),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.style,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Build Your Deck',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Select heroes strategically for victory',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(deck, fillPercentage),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${deck.deckSize} Heroes Selected',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '$fillPercentage%',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(DeckProvider deck, String fillPercentage) {
    final fillPercent = deck.deckSize / DeckProvider.maxDeckSize;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LinearProgressIndicator(
        value: fillPercent,
        minHeight: 8,
        backgroundColor: Colors.white.withValues(alpha:0.1),
        valueColor: AlwaysStoppedAnimation<Color>(
          fillPercent == 1.0
              ? Colors.greenAccent
              : const Color(0xFF7B2FBE),
        ),
      ),
    );
  }

  Widget _buildDeckContent(DeckProvider deck, ThemeData theme) {
    if (deck.deck.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.collections_bookmark_outlined,
                size: 64,
                color: Colors.white.withValues(alpha:0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No heroes yet',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add heroes from the Home screen to build your deck',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, RouteNames.home),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Your Heroes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        ...deck.deck.asMap().entries.map((entry) {
          final index = entry.key;
          final hero = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildDeckHeroCard(hero, index, deck, theme),
          );
        }),
      ],
    );
  }

  Widget _buildDeckHeroCard(HeroModel hero, int index, DeckProvider deck, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha:0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha:0.4),
                    theme.colorScheme.primary.withValues(alpha:0.2),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    hero.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      _buildStatChip('HP', hero.maxHp.toString(), Colors.greenAccent),
                      const SizedBox(width: 6),
                      _buildStatChip('ATK', hero.attack.toString(), Colors.redAccent),
                      const SizedBox(width: 6),
                      _buildStatChip('DEF', hero.defense.toString(), Colors.blueAccent),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              color: Colors.white54,
              onPressed: () {
                deck.removeHero(hero);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${hero.name} removed from deck'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha:0.15),
        border: Border.all(color: color.withValues(alpha:0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckActions(DeckProvider deck, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha:0.1),
          ),
        ),
        color: Colors.black.withValues(alpha:0.3),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  onPressed: deck.deck.isEmpty ? null : () => _promptSaveDeck(deck),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Deck'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: deck.isReady
                      ? () {
                          context.read<BattleProvider>().reset(notify: false);
                          Navigator.pushNamed(context, RouteNames.battle);
                        }
                      : null,
                  icon: const Icon(Icons.sports_martial_arts),
                  label: const Text('Battle'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => Navigator.pushNamed(context, RouteNames.savedDecks),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('View Saved Decks'),
            ),
          ),
        ],
      ),
    );
  }
}


