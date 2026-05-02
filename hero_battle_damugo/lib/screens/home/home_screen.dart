import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_config.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../router/app_router.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hero_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const String _openDrawerArg = 'openDrawer';
  static const String _fromDrawerArg = 'fromDrawer';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SuperheroApiService _api =
      SuperheroApiService(apiToken: AppConfig.superheroApiToken);
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _searchFocusNode;
  AnimationController? _sheenController;
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
    _searchFocusNode = FocusNode()
      ..addListener(() {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    _ensureSheenController();
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
    _searchFocusNode.dispose();
    _sheenController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _ensureSheenController() {
    if (_sheenController != null) {
      return;
    }
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  Widget _buildCinematicTopStrip() {
    _ensureSheenController();

    final sheenTravel = Tween<double>(begin: -1.2, end: 1.2).animate(
      CurvedAnimation(parent: _sheenController!, curve: Curves.easeInOut),
    );

    return SizedBox(
      height: 4,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    const Color(0xFFB08A44).withValues(alpha: 0.68),
                    const Color(0xFFFAE3A8).withValues(alpha: 0.92),
                    const Color(0xFFD7B066).withValues(alpha: 0.76),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _sheenController!,
              builder: (context, child) {
                return Align(
                  alignment: Alignment(sheenTravel.value, 0),
                  child: child,
                );
              },
              child: FractionallySizedBox(
                widthFactor: 0.28,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.5),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickySearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isFocused = _searchFocusNode.hasFocus;
    final accent = isDark ? const Color(0xFFE9D7AA) : const Color(0xFF8E6A2A);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? <Color>[
                    const Color(0xFFE8D6AA).withValues(alpha: isFocused ? 0.72 : 0.5),
                    const Color(0xFF8A7447).withValues(alpha: isFocused ? 0.34 : 0.18),
                  ]
                : <Color>[
                    const Color(0xFFAA8A49).withValues(alpha: isFocused ? 0.48 : 0.3),
                    Colors.white.withValues(alpha: isFocused ? 0.92 : 0.86),
                  ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            setState(() {
              _searchInput = value;
            });
            _runSearch(value);
          },
          onSubmitted: (value) => _runSearch(value, immediate: true),
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Search hero by name',
            hintStyle: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.66),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: accent,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward),
              color: scheme.onSurface,
              tooltip: 'Search',
              onPressed: () => _runSearch(_searchController.text, immediate: true),
            ),
            filled: true,
            fillColor: isDark
                ? (isFocused ? const Color(0xFF252C39) : const Color(0xFF2A303C))
                : (isFocused
                    ? scheme.surfaceContainerHigh
                    : scheme.surfaceContainerLow),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: scheme.onSurface.withValues(alpha: 0.22),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accent.withValues(alpha: 0.94),
                width: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final search = context.watch<HeroSearchProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFFE8D6AA) : const Color(0xFF8E6A2A);
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        width: MediaQuery.of(context).size.width.clamp(300.0, 360.0),
        elevation: 0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const <Color>[
                      Color(0xFF111626),
                      Color(0xFF0E1322),
                      Color(0xFF0B1020),
                    ]
                  : <Color>[
                      scheme.surface,
                      scheme.surfaceContainerLowest,
                      scheme.surfaceContainerLow,
                    ],
            ),
            border: Border(
              right: BorderSide(
                color: accent.withValues(alpha: isDark ? 0.16 : 0.22),
              ),
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? <Color>[
                              Colors.white.withValues(alpha: 0.07),
                              Colors.white.withValues(alpha: 0.03),
                            ]
                          : <Color>[
                              Colors.black.withValues(alpha: 0.035),
                              Colors.black.withValues(alpha: 0.015),
                            ],
                    ),
                    border: Border.all(
                      color: accent.withValues(alpha: isDark ? 0.18 : 0.26),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                              const Color(0xFFF7E4BB),
                              isDark ? const Color(0xFFD6A44C) : const Color(0xFFB78935),
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.shield,
                          color: Color(0xFF20180A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Hero Battle',
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Command Center',
                              style: TextStyle(
                                color: scheme.onSurface.withValues(alpha: 0.74),
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
                        color: accent.withValues(alpha: 0.72),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Fight smart. Build better decks.',
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.72),
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
        backgroundColor: isDark ? const Color(0xFF10131B) : scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: isDark ? const Color(0xFF10131B) : scheme.surface,
        flexibleSpace: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const <Color>[
                      Color(0xFF0F121A),
                      Color(0xFF121722),
                      Color(0xFF161C28),
                    ]
                  : <Color>[
                      scheme.surface,
                      scheme.surfaceContainerLowest,
                      scheme.surface,
                    ],
            ),
            border: Border(
              bottom: BorderSide(
                color: scheme.onSurface.withValues(alpha: 0.14),
              ),
            ),
          ),
        ),
        bottomOpacity: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          tooltip: 'Open navigation',
          onPressed: _openDrawerWhenReady,
        ),
        title: const Text('Hero Roster'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(78),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildCinematicTopStrip(),
              _buildStickySearchBar(context),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: isDark ? 0.08 : 0.04),
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: 0.16),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu_book_rounded),
              tooltip: 'Game Manual',
              onPressed: _showGameManualDialog,
            ),
          ),
          Consumer<DeckProvider>(
            builder: (context, deck, _) => Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: isDark ? 0.08 : 0.04),
                    border: Border.all(
                      color: scheme.onSurface.withValues(alpha: 0.16),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.style),
                    tooltip: 'Deck Builder',
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteNames.deckBuilder),
                  ),
                ),
                if (deck.deckSize > 0)
                  Positioned(
                    right: 10,
                    top: 6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: accent,
                        border: Border.all(
                          color: isDark ? const Color(0xFF0F1D24) : const Color(0xFF5F451D),
                        ),
                      ),
                      child: Text(
                        '${deck.deckSize}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? const Color(0xFF081116) : const Color(0xFF2B1F0F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/baselayerBG.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white)
                  .withValues(alpha: isDark ? 0.28 : 0.36),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
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
                      return _buildGrid(heroes);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showGameManualDialog() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Widget sectionTitle(String text) {
      return Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      );
    }

    Widget sectionBody(List<String> lines) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines
            .map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  line,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: scheme.onSurface.withValues(alpha: 0.9),
                  ),
                ),
              ),
            )
            .toList(),
      );
    }

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 620),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: scheme.surface,
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: isDark ? 0.16 : 0.12),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.12),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 14, 10, 14),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? <Color>[
                                const Color(0xFF283248),
                                const Color(0xFF1E2638),
                              ]
                            : <Color>[
                                const Color(0xFFEFF3FF),
                                const Color(0xFFE5ECFF),
                              ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: scheme.onSurface.withValues(alpha: isDark ? 0.2 : 0.14),
                        ),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.menu_book_rounded,
                          color: isDark ? const Color(0xFFC4D5FF) : const Color(0xFF3959B8),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Hero Battle Manual',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          sectionTitle('About the Game'),
                          const SizedBox(height: 8),
                          sectionBody(<String>[
                            'Hero Battle is a 5v5 team duel. Each side fields five heroes, and only one hero is active at a time.',
                            'Every round, both active heroes exchange damage based on their stats. If a hero reaches 0 HP, they are knocked out and the next hero takes over.',
                            'The team with at least one hero standing at the end wins the match.',
                          ]),
                          const SizedBox(height: 14),
                          sectionTitle('Before You Play'),
                          const SizedBox(height: 8),
                          sectionBody(<String>[
                            'Build a full deck of 5 heroes in Deck Builder.',
                            'Balance your team: high HP heroes can soak damage, while high attack heroes can close rounds quickly.',
                            'You can use Random Fill if you want a quick team, then replace cards manually.',
                          ]),
                          const SizedBox(height: 14),
                          sectionTitle('How to Play'),
                          const SizedBox(height: 8),
                          sectionBody(<String>[
                            '1. Open Battle and press Start Battle once your deck has 5 heroes.',
                            '2. Watch both active heroes clash each round.',
                            '3. Tap a bench hero in your team strip to switch before the next turn when needed.',
                            '4. Use battle log and HP bars to track momentum and make better switch decisions.',
                            '5. After a match, start a New Battle or review previous matches in History.',
                          ]),
                          const SizedBox(height: 14),
                          sectionTitle('Tips'),
                          const SizedBox(height: 8),
                          sectionBody(<String>[
                            'Save strong deck combinations for quick reuse.',
                            'Do not switch too often if your current hero still has strong HP advantage.',
                            'If your active hero is low, switch early to avoid losing round tempo.',
                          ]),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Got it'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  Future<void> _showDeckNoticeDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color accent,
  }) {
    final theme = Theme.of(context);

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF26222F),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.18),
                          border: Border.all(color: accent.withValues(alpha: 0.4)),
                        ),
                        child: Icon(icon, size: 20, color: accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.86),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accent.withValues(alpha: 0.9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Got it'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<HeroModel> heroes) {
    _ensureSheenController();

    final args = ModalRoute.of(context)?.settings.arguments;
    final fromDeckBuilder = args is Map<String, dynamic> && args['fromDeckBuilder'] == true;
    final deck = context.read<DeckProvider>();

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      clipBehavior: Clip.none,
      itemCount: heroes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, i) {
        final hero = heroes[i];
        final inDeck = deck.contains(hero);
        final isAddable = !inDeck && !deck.isFull;

        return Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedBuilder(
            animation: _sheenController!,
            builder: (context, child) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  child!,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _CardBorderShimmerPainter(
                          progress: _sheenController!.value,
                          borderRadius: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFFFFFAE8),
                    Color(0xFFFFE8AE),
                    Color(0xFFFFCF74),
                    Color(0xFFE4A84A),
                    Color(0xFFFFDC8D),
                  ],
                  stops: <double>[0.0, 0.22, 0.5, 0.82, 1.0],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.38),
                  width: 0.65,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.24),
                    blurRadius: 8,
                    spreadRadius: 0.2,
                    offset: const Offset(-2, -2),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFD77B).withValues(alpha: 0.22),
                    blurRadius: 16,
                    spreadRadius: 1.0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 12,
                    spreadRadius: 0.3,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.2),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.2),
                    color: Colors.black.withValues(alpha: 0.14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.26),
                      width: 0.55,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: HeroCard(
                      hero: hero,
                      onTap: () {
                        if (fromDeckBuilder && inDeck) {
                          _showDeckNoticeDialog(
                            title: 'Duplicate Card',
                            message: 'This card is already existing in your deck of cards. No duplicate card allowed.',
                            icon: Icons.copy_rounded,
                            accent: Colors.orangeAccent,
                          );
                        } else if (fromDeckBuilder && deck.isFull && !inDeck) {
                          _showDeckNoticeDialog(
                            title: 'Deck Full',
                            message: 'You already have 5 cards in your deck. Remove a card to add a new one.',
                            icon: Icons.layers_clear_rounded,
                            accent: Colors.redAccent,
                          );
                        } else if (fromDeckBuilder && isAddable) {
                          deck.addHero(hero);
                          Navigator.pop(context);
                        } else if (!fromDeckBuilder) {
                          Navigator.pushNamed(
                            context,
                            RouteNames.heroDetail,
                            arguments: hero,
                          );
                        }
                      },
                      trailing: fromDeckBuilder
                          ? Icon(
                              inDeck ? Icons.check_circle : (deck.isFull ? Icons.block : Icons.add_circle_outline),
                              color: inDeck ? Colors.green : (deck.isFull ? Colors.grey : null),
                            )
                          : Icon(
                              inDeck ? Icons.check_circle : Icons.add_circle_outline,
                              color: inDeck ? Colors.green : null,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CardBorderShimmerPainter extends CustomPainter {
  _CardBorderShimmerPainter({
    required this.progress,
    required this.borderRadius,
  });

  final double progress;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(0.8), Radius.circular(borderRadius));

    final baseStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85
      ..color = Colors.white.withValues(alpha: 0.18);
    canvas.drawRRect(rrect, baseStroke);

    // Show directional sheen only for part of the cycle, then pause.
    const activeWindow = 0.62;
    if (progress > activeWindow) {
      return;
    }

    final bandProgress = Curves.easeOutCubic.transform(progress / activeWindow);
    final innerRadius = borderRadius > 2.2 ? borderRadius - 2.2 : 0.0;
    final outerPath = Path()..addRRect(rrect);
    final innerPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect.deflate(2.2), Radius.circular(innerRadius)),
      );
    final borderRingPath = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );

    final travelX = (-size.width * 0.35) + ((size.width * 1.7) * bandProgress);
    final bandRect = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.36,
      height: size.height * 2.2,
    );
    final bandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[
          Colors.transparent,
          const Color(0xFFFFD988).withValues(alpha: 0.18),
          const Color(0xFFFFF7DD).withValues(alpha: 0.92),
          const Color(0xFFFFD988).withValues(alpha: 0.18),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 0.34, 0.5, 0.66, 1.0],
      ).createShader(bandRect);

    canvas.save();
    canvas.clipPath(borderRingPath);
    canvas.translate(travelX, size.height * 0.5);
    canvas.rotate(-0.42);
    canvas.drawRect(bandRect, bandPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CardBorderShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.borderRadius != borderRadius;
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
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final selectedColor = isDark ? const Color(0xFFE8D6AA) : const Color(0xFF8E6A2A);

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
                  ? (isDark
                      ? const Color(0xFF3B3550).withValues(alpha: 0.88)
                      : selectedColor.withValues(alpha: 0.14))
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.035)
                      : Colors.black.withValues(alpha: 0.02)),
              border: Border.all(
                color: selected
                    ? selectedColor.withValues(alpha: 0.64)
                    : scheme.onSurface.withValues(alpha: 0.14),
              ),
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: selectedColor.withValues(alpha: 0.12),
                        blurRadius: 8,
                        spreadRadius: 0.4,
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 21,
                  color: selected
                      ? selectedColor
                      : scheme.onSurface.withValues(alpha: 0.84),
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
                          : scheme.onSurface.withValues(alpha: 0.9),
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