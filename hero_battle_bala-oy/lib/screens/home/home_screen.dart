import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_config.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../providers/player_provider.dart';
import '../../router/app_router.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hero_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _openDrawerArg = 'openDrawer';
  static const String _fromDrawerArg = 'fromDrawer';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SuperheroApiService _api =
      SuperheroApiService(apiToken: AppConfig.superheroApiToken);
  final TextEditingController _searchController = TextEditingController();
  late Future<List<HeroModel>> _heroesFuture;
  String _searchInput = '';
  Timer? _searchDebounce;
  Object? _lastHandledDrawerArgs;

  void _openDrawerWhenReady({int attempt = 0}) {
    if (!mounted) {
      return;
    }

    final state = _scaffoldKey.currentState;
    if (state != null) {
      if (!state.isDrawerOpen) {
        state.openDrawer();
      }
      return;
    }

    if (attempt >= 5) {
      return;
    }

    unawaited(
      Future<void>.delayed(
        const Duration(milliseconds: 90),
        () => _openDrawerWhenReady(attempt: attempt + 1),
      ),
    );
  }

  void _runSearch(String value, {bool immediate = false}) {
    final trimmed = value.trim();

    _searchDebounce?.cancel();
    if (immediate) {
      context.read<HeroSearchProvider>().setQuery(trimmed, _api);
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) {
        return;
      }
      context.read<HeroSearchProvider>().setQuery(trimmed, _api);
    });
  }

  @override
  void initState() {
    super.initState();
    _heroesFuture = _api.fetchRandomHeroes(count: 20);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = context.read<HeroSearchProvider>();
      searchProvider.hydrateLastSearch().then((_) async {
        if (!mounted) {
          return;
        }
        final restored = searchProvider.query;
        _searchController.text = restored;
        setState(() {
          _searchInput = restored;
        });
        if (restored.isNotEmpty) {
          await searchProvider.setQuery(restored, _api);
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    final shouldOpenDrawer =
        args is Map<String, dynamic> && args[_openDrawerArg] == true;
    if (!shouldOpenDrawer || identical(_lastHandledDrawerArgs, args)) {
      return;
    }

    _lastHandledDrawerArgs = args;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _openDrawerWhenReady();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = context.watch<HeroSearchProvider>();
    final deck = context.watch<DeckProvider>();
    final theme = Theme.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        width: MediaQuery.of(context).size.width.clamp(300.0, 360.0),
        elevation: 0,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF181627), Color(0xFF120F20)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: <Color>[
                              theme.colorScheme.primary,
                              theme.colorScheme.tertiary,
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.shield,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Hero Battle',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Command Center',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    children: <Widget>[
                      _DrawerNavTile(
                        label: 'Home',
                        icon: Icons.home_rounded,
                        selected: currentRoute == RouteNames.home,
                        onTap: () => _navigateFromDrawer(RouteNames.home),
                      ),
                      _DrawerNavTile(
                        label: 'Deck Builder',
                        icon: Icons.style_rounded,
                        selected: currentRoute == RouteNames.deckBuilder,
                        onTap: () =>
                            _navigateFromDrawer(RouteNames.deckBuilder),
                      ),
                      _DrawerNavTile(
                        label: 'Battle',
                        icon: Icons.sports_martial_arts_rounded,
                        selected: currentRoute == RouteNames.battle,
                        onTap: () => _navigateFromDrawer(RouteNames.battle),
                      ),
                      _DrawerNavTile(
                        label: 'History',
                        icon: Icons.history_rounded,
                        selected: currentRoute == RouteNames.history,
                        onTap: () => _navigateFromDrawer(RouteNames.history),
                      ),
                      _DrawerNavTile(
                        label: 'Profile',
                        icon: Icons.person_rounded,
                        selected: currentRoute == RouteNames.profile,
                        onTap: () => _navigateFromDrawer(RouteNames.profile),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white.withValues(alpha: 0.45),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Fight smart. Build better decks.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.58),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Hero Roster'),
        actions: [
          Consumer<DeckProvider>(
            builder: (context, deck, _) => Stack(
              alignment: Alignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.style),
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.deckBuilder),
                ),
                if (deck.deckSize > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 8,
                      child: Text(
                        '${deck.deckSize}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: <Widget>[
                _buildHomeHeader(deck, theme),
                const SizedBox(height: 14),
                _buildSearchCard(theme),
                const SizedBox(height: 14),
                Expanded(
                  child: FutureBuilder<List<HeroModel>>(
                    future: _heroesFuture,
                    builder: (context, snapshot) {
                      if (search.query.isNotEmpty || _searchInput.isNotEmpty) {
                        if (search.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (search.error != null) {
                          return Center(child: Text(search.error!));
                        }
                        if (search.results.isEmpty) {
                          return const Center(
                            child: Text('No heroes found.'),
                          );
                        }
                        return _buildGrid(search.results);
                      }

                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: FilledButton.tonal(
                            onPressed: () {
                              setState(() {
                                _heroesFuture = _api.fetchRandomHeroes(count: 20);
                              });
                            },
                            child: const Text('Retry loading heroes'),
                          ),
                        );
                      }
                      final heroes = snapshot.data ?? <HeroModel>[];
                      return _buildCategorizedView(heroes, deck);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeHeader(DeckProvider deck, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            theme.colorScheme.secondary.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Enter the arena',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your champions wisely. Every choice shapes your destiny.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white60,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildFeatureCard(
                  label: 'Deck',
                  value: '${deck.deckSize}',
                  icon: Icons.style,
                  accent: Colors.purpleAccent,
                  onTap: () => Navigator.pushNamed(context, RouteNames.deckBuilder),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  label: 'Ready',
                  value: 'Battle',
                  icon: Icons.sports_martial_arts_rounded,
                  accent: Colors.amberAccent,
                  onTap: () => Navigator.pushNamed(context, RouteNames.battle),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildActionButton(
                  label: 'Profile',
                  icon: Icons.person_rounded,
                  accent: Colors.blueAccent,
                  onTap: () => Navigator.pushNamed(context, RouteNames.profile),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  label: 'Settings',
                  icon: Icons.settings_rounded,
                  accent: Colors.greenAccent,
                  onTap: () => _showSettingsDialog(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.18),
              accent.withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(
            color: accent.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.4),
                    accent.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  setState(() {
                    _searchInput = value;
                  });
                  _runSearch(value);
                },
                onSubmitted: (value) => _runSearch(value, immediate: true),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Search heroes...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  suffixIcon: _searchInput.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: Colors.white.withValues(alpha: 0.6),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchInput = '';
                            });
                            context.read<HeroSearchProvider>().clear();
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.25),
              accent.withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(
            color: accent.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.6),
                    accent.withValues(alpha: 0.3),
                  ],
                ),
                border: Border.all(
                  color: accent.withValues(alpha: 0.8),
                  width: 2,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final player = context.read<PlayerProvider>();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1D35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.settings_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: Row(
                children: [
                  Icon(
                    player.isDarkTheme
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: Colors.indigoAccent,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Dark Theme',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Switch(
                    value: player.isDarkTheme,
                    onChanged: (_) {
                      context.read<PlayerProvider>().toggleTheme();
                      Navigator.of(context).pop();
                    },
                    thumbColor: WidgetStatePropertyAll(theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateFromDrawer(String routeName) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    Navigator.pop(context);

    if (currentRoute == routeName) {
      return;
    }

    unawaited(
      Future<void>.delayed(Duration.zero, () {
        if (!mounted) {
          return;
        }
        Navigator.pushReplacementNamed(
          context,
          routeName,
          arguments: <String, dynamic>{_fromDrawerArg: true},
        );
      }),
    );
  }

  Widget _buildGrid(List<HeroModel> heroes) {
    return GridView.builder(
      itemCount: heroes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (_, i) {
        final hero = heroes[i];
        final inDeck = context.read<DeckProvider>().contains(hero);
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            RouteNames.heroDetail,
            arguments: hero,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
              border: Border.all(
                color: inDeck
                    ? Colors.purpleAccent.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.1),
                width: inDeck ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: inDeck
                      ? Colors.purpleAccent.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.3),
                  blurRadius: inDeck ? 16 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Hero Card
                HeroCard(
                  hero: hero,
                  onTap: () => Navigator.pushNamed(
                    context,
                    RouteNames.heroDetail,
                    arguments: hero,
                  ),
                ),
                // Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: inDeck
                          ? Colors.purpleAccent.withValues(alpha: 0.8)
                          : Colors.black.withValues(alpha: 0.5),
                      border: Border.all(
                        color: inDeck
                            ? Colors.purpleAccent
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      inDeck ? Icons.check_circle : Icons.add_circle_outline,
                      size: 16,
                      color: inDeck ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, List<HeroModel>> _categorizeHeroes(List<HeroModel> heroes) {
    final categories = <String, List<HeroModel>>{
      'Strength Heroes': [],
      'Intelligent Heroes': [],
      'Speed Heroes': [],
      'Durable Heroes': [],
    };

    for (final hero in heroes) {
      if (hero.powerStats.strength > 80) {
        categories['Strength Heroes']!.add(hero);
      } else if (hero.powerStats.intelligence > 80) {
        categories['Intelligent Heroes']!.add(hero);
      } else if (hero.powerStats.speed > 80) {
        categories['Speed Heroes']!.add(hero);
      } else if (hero.powerStats.durability > 80) {
        categories['Durable Heroes']!.add(hero);
      }
    }

    categories.removeWhere((k, v) => v.isEmpty);
    if (heroes.isNotEmpty) {
      categories['All Heroes'] = heroes.take(8).toList();
    }

    return categories;
  }

  Widget _buildCategorizedView(List<HeroModel> heroes, DeckProvider deck) {
    final categories = _categorizeHeroes(heroes);

    return ListView(
      children: [
        if (categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Featured Groups',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        ...categories.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _buildCategorySection(
              title: entry.key,
              heroes: entry.value,
              deck: deck,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCategorySection({
    required String title,
    required List<HeroModel> heroes,
    required DeckProvider deck,
  }) {
    final colors = {
      'Strength Heroes': Colors.redAccent,
      'Intelligent Heroes': Colors.blueAccent,
      'Speed Heroes': Colors.cyan,
      'Durable Heroes': Colors.greenAccent,
      'All Heroes': Colors.amberAccent,
    };

    final icons = {
      'Strength Heroes': Icons.fitness_center_rounded,
      'Intelligent Heroes': Icons.psychology_rounded,
      'Speed Heroes': Icons.local_fire_department_rounded,
      'Durable Heroes': Icons.shield_rounded,
      'All Heroes': Icons.stars_rounded,
    };

    final accentColor = colors[title] ?? Colors.purpleAccent;
    final icon = icons[title] ?? Icons.auto_awesome_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha:0.3),
                      accentColor.withValues(alpha:0.1),
                    ],
                  ),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
              ),
              const Spacer(),
              Text(
                '${heroes.length} heroes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: heroes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (_, i) {
            final hero = heroes[i];
            final inDeck = deck.contains(hero);
            return _buildHeroCard(hero, inDeck);
          },
        ),
      ],
    );
  }

  Widget _buildHeroCard(HeroModel hero, bool inDeck) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        RouteNames.heroDetail,
        arguments: hero,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.08),
              Colors.white.withValues(alpha: 0.02),
            ],
          ),
          border: Border.all(
            color: inDeck
                ? Colors.purpleAccent.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
            width: inDeck ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: inDeck
                  ? Colors.purpleAccent.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: inDeck ? 16 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            HeroCard(
              hero: hero,
              onTap: () => Navigator.pushNamed(
                context,
                RouteNames.heroDetail,
                arguments: hero,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: inDeck
                      ? Colors.purpleAccent.withValues(alpha: 0.8)
                      : Colors.black.withValues(alpha: 0.5),
                  border: Border.all(
                    color: inDeck
                        ? Colors.purpleAccent
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  inDeck ? Icons.check_circle : Icons.add_circle_outline,
                  size: 16,
                  color: inDeck ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: selected
                  ? selectedColor.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.03),
              border: Border.all(
                color: selected
                    ? selectedColor.withValues(alpha: 0.60)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 21,
                  color: selected
                      ? selectedColor
                      : Colors.white.withValues(alpha: 0.86),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? selectedColor
                          : Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
