import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_config.dart';
import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hero_image.dart';

class BanPhaseScreen extends StatefulWidget {
  final VoidCallback onBanningComplete;

  const BanPhaseScreen({
    super.key,
    required this.onBanningComplete,
  });

  @override
  State<BanPhaseScreen> createState() => _BanPhaseScreenState();
}

class _BanPhaseScreenState extends State<BanPhaseScreen>
    with TickerProviderStateMixin {
  final SuperheroApiService _api = SuperheroApiService(
    apiToken: AppConfig.superheroApiToken,
  );

  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  String _searchQuery = '';
  bool _isSearchLoading = false;
  List<HeroModel> _searchResults = <HeroModel>[];
  String? _searchError;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _fadeController.forward();
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final trimmed = value.trim();

    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) {
        return;
      }

      setState(() {
        _searchQuery = trimmed.toLowerCase();
        _isSearchLoading = _searchQuery.isNotEmpty;
        _searchError = null;
        if (_searchQuery.isEmpty) {
          _searchResults = <HeroModel>[];
        }
      });

      if (_searchQuery.isEmpty) {
        return;
      }

      try {
        final results = await _api.searchHeroes(_searchQuery);
        if (!mounted || _searchQuery != trimmed.toLowerCase()) {
          return;
        }

        results.sort((a, b) => _heroScore(b).compareTo(_heroScore(a)));
        setState(() {
          _searchResults = results;
          _searchError = null;
        });
      } catch (_) {
        if (!mounted || _searchQuery != trimmed.toLowerCase()) {
          return;
        }
        setState(() {
          _searchResults = <HeroModel>[];
          _searchError = 'Failed to search heroes';
        });
      } finally {
        if (mounted && _searchQuery == trimmed.toLowerCase()) {
          setState(() {
            _isSearchLoading = false;
          });
        }
      }
    });
  }

  int _heroScore(HeroModel hero) {
    return hero.maxHp + hero.attack + hero.specialAttack + hero.defense + hero.initiative;
  }

  List<HeroModel> _getDisplayedHeroes(List<HeroModel> heroes) {
    if (_searchQuery.isEmpty) {
      return heroes;
    }
    return _searchResults;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BattleProvider>(
      builder: (context, battleProvider, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final accent = isDark ? const Color(0xFFE8D6AA) : const Color(0xFF8E6A2A);
        final heroes = battleProvider.availableHeroesForBanning;
        final displayedHeroes = _getDisplayedHeroes(heroes);
        final playerBanned = battleProvider.playerBannedHeroes;
        final aiBanned = battleProvider.aiEnemyBannedHeroes;
        final isPlayerTurn = battleProvider.isPlayerTurnToBan;
        final bansPerSide = battleProvider.bansPerSide;

        if (!battleProvider.isInBanningPhase) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onBanningComplete();
          });
          return const SizedBox.shrink();
        }

        return FadeTransition(
          opacity: _fadeController,
          child: Scaffold(
            backgroundColor: scheme.surface,
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? <Color>[
                                const Color(0xFF121828),
                                const Color(0xFF0F1422),
                              ]
                            : <Color>[
                                scheme.surface,
                                scheme.surfaceContainerLow,
                              ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: accent.withValues(alpha: isDark ? 0.42 : 0.36),
                          width: 1.3,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'BANNING PHASE',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            Row(
                              children: [
                                _buildBanCounter(
                                  context,
                                  'You',
                                  playerBanned.length,
                                  bansPerSide,
                                  accent,
                                ),
                                const SizedBox(width: 20),
                                _buildBanCounter(
                                  context,
                                  'Opponent',
                                  aiBanned.length,
                                  bansPerSide,
                                  accent,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isPlayerTurn
                              ? 'Your Turn - Ban ${bansPerSide - playerBanned.length} more hero(es)'
                              : 'Opponent is banning...',
                          style: TextStyle(
                            fontSize: 14,
                            color: isPlayerTurn
                                ? (isDark ? const Color(0xFF52E39B) : const Color(0xFF147A45))
                                : (isDark ? const Color(0xFFFFC46B) : const Color(0xFF9A5A00)),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF111827)
                          : scheme.surfaceContainerLowest,
                      border: Border(
                        bottom: BorderSide(
                          color: accent.withValues(alpha: isDark ? 0.22 : 0.18),
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _onSearchChanged,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search heroes...',
                        hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.58)),
                        prefixIcon: Icon(
                          Icons.search,
                          color: accent,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: scheme.onSurface.withValues(alpha: 0.72),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchFocusNode.unfocus();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF171E2F)
                            : scheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: accent.withValues(alpha: isDark ? 0.38 : 0.26),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: accent.withValues(alpha: isDark ? 0.38 : 0.26),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: accent.withValues(alpha: 0.92),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? <Color>[
                                  const Color(0xFF0E1420),
                                  const Color(0xFF0B101A),
                                ]
                              : <Color>[
                                  scheme.surfaceContainerLowest,
                                  scheme.surface,
                                ],
                        ),
                      ),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _scaleController,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: _isSearchLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                                ),
                              )
                            : displayedHeroes.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Text(
                                        _searchQuery.isEmpty
                                            ? 'No heroes available for banning'
                                            : _searchError != null
                                                ? _searchError!
                                                : 'No heroes found matching "$_searchQuery"',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: scheme.onSurface.withValues(alpha: 0.62),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    padding: const EdgeInsets.all(12),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.7,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount: displayedHeroes.length,
                                      itemBuilder: (context, index) {
                                        final hero = displayedHeroes[index];
                                        return _buildHeroCard(
                                          context,
                                          hero,
                                          playerBanned.contains(hero.name),
                                          aiBanned.contains(hero.name),
                                          isPlayerTurn && playerBanned.length < bansPerSide,
                                          battleProvider,
                                        );
                                      },
                                    ),
                                  ),
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

  Widget _buildBanCounter(
    BuildContext context,
    String label,
    int current,
    int total,
    Color accent,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurface.withValues(alpha: 0.72),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C2540).withValues(alpha: 0.82)
                : scheme.surfaceContainerHigh,
            border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.54 : 0.42),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$current / $total',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    HeroModel hero,
    bool playerBanned,
    bool aiIsBanned,
    bool canBan,
    BattleProvider battleProvider,
  ) {
    final isBanned = playerBanned || aiIsBanned;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 2.5 : 1.2,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
      child: InkWell(
        onTap: !isBanned && canBan
            ? () {
                battleProvider.playerBanHero(hero.name);
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  HeroImage(
                    urls: hero.displayImageCandidates,
                    heroId: hero.id,
                    heroName: hero.name,
                    searchTerms: hero.imageSearchTerms,
                    fit: BoxFit.cover,
                    loading: Container(
                      color: Colors.black26,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            scheme.primary,
                          ),
                        ),
                      ),
                    ),
                    error: Container(
                      color: Colors.black26,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.25),
                            Colors.black.withValues(alpha: 0.72),
                          ],
                          stops: const <double>[0.45, 0.68, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          hero.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            shadows: <Shadow>[
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _StatPentagon(
                              value: hero.maxHp,
                              fillColor: Colors.red.shade700,
                            ),
                            _StatPentagon(
                              value: hero.defense,
                              fillColor: Colors.blue.shade700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isBanned)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.6),
                        child: Center(
          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.block_rounded,
                                  size: 36,
                                  color: playerBanned
                                      ? const Color(0xFFFF1744)
                                      : const Color(0xFFFF9100),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  playerBanned ? 'YOUR BAN' : 'OPP BAN',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: playerBanned
                                        ? const Color(0xFFFF1744)
                                        : const Color(0xFFFF9100),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
              child: Text(
                hero.publisher.isEmpty ? 'Unknown Publisher' : hero.publisher,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPentagon extends StatelessWidget {
  const _StatPentagon({
    required this.value,
    required this.fillColor,
  });

  final int value;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ) ??
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        );

    return CustomPaint(
      painter: _PentagonPainter(fillColor: fillColor),
      child: SizedBox(
        width: 46,
        height: 46,
        child: Center(
          child: Text(
            value.toString(),
            style: textStyle.copyWith(fontSize: 12.5),
          ),
        ),
      ),
    );
  }
}

class _PentagonPainter extends CustomPainter {
  _PentagonPainter({required this.fillColor});

  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final path = Path();

    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / 5);
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final fill = Paint()..color = fillColor;
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _PentagonPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor;
  }
}
