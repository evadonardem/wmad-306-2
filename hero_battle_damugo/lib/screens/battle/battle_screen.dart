import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app_config.dart';
import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/player_provider.dart';
import '../../router/app_router.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/battle_hero_card.dart';
import '../../widgets/hero_image.dart';
import '../../widgets/hp_bar.dart';
import 'ban_phase_screen.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with TickerProviderStateMixin {
  static const String _openDrawerArg = 'openDrawer';
  static const String _fromDrawerArg = 'fromDrawer';

  final SuperheroApiService _api = SuperheroApiService(
    apiToken: AppConfig.superheroApiToken,
  );

  Future<List<HeroModel>>? _aiTeamFuture;
  Future<List<HeroModel>>? _banPoolFuture;
  List<HeroModel> _currentAiTeam = [];
  Timer? _autoAdvanceTimer;
  Timer? _impactFxTimer;
  AnimationController? _clashController;
  AnimationController? _shakeController;
  AnimationController? _victoryController;
  AnimationController? _introController;
  AnimationController? _statusPulseController;
  AnimationController? _impactFxController;
  Animation<double>? _clashProgress;
  Animation<double>? _clashFlash;
  final ScrollController _battleLogController = ScrollController();
  int _lastBattleLogCount = 0;
  int _turnCountdown = 0;
  int _preBattlePlayerIndex = 0;
  bool _isAnimatingTurn = false;
  bool _isResolvingTurn = false;
  bool _winRecorded = false;
  bool _isScreenReady = false;
  bool _manualNextTurnRequired = false;
  bool _isResultOverlayDismissed = false;
  bool _showCinematicIntro = false;
  bool _isInBanningPhase = false;
  bool _isPreparingBanPhase = false;
  _BattleImpactFx? _currentImpactFx;
  String _roundFeedback = '';
  int _arenaBackgroundIndex = 0;

  static const int _autoAdvanceSeconds = 5;
  static const List<String> _arenaBackgrounds = <String>[
    'assets/images/arena.png',
    'assets/images/secondArena.png',
    'assets/images/thirdArena.png',
    'assets/images/fourthArena.png',
    'assets/images/fifthArena.png',
  ];

  void _initializeBattleControllers() {
    _clashController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shakeController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _victoryController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _introController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _statusPulseController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _impactFxController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );

    _clashProgress ??= TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0.8,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.8,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_clashController!);

    _clashFlash ??= CurvedAnimation(
      parent: _clashController!,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
    );
  }

  void _goBack() {
    _goHome();
  }

  void _onBanningPhaseComplete() {
    final provider = context.read<BattleProvider>();
    final deck = context.read<DeckProvider>();
    
    setState(() {
      _isInBanningPhase = false;
    });

    // After banning is complete, start the actual battle with filtered teams
    Future<void>.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) {
        return;
      }

      _winRecorded = false;
      provider.startBattle(
        playerTeam: deck.deck,
        aiTeam: _currentAiTeam,
        playerStartingIndex: _preBattlePlayerIndex,
      );
      _manualNextTurnRequired = false;
      await _playCinematicIntro();
      if (!mounted) {
        return;
      }
      _scheduleAutoAdvance(provider);
    });
  }

  bool _openedFromDrawer() {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is Map<String, dynamic> && args[_fromDrawerArg] == true;
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      RouteNames.home,
      (route) => false,
      arguments: _openedFromDrawer()
          ? <String, dynamic>{_openDrawerArg: true}
          : null,
    );
  }

  void _openDeckBuilder() {
    Navigator.pushNamed(context, RouteNames.deckBuilder);
  }

  @override
  void initState() {
    super.initState();
    _initializeBattleControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        context.read<BattleProvider>().reset();
        _aiTeamFuture = _loadAiTeam();
        _banPoolFuture = _loadBanPool();
        _isScreenReady = true;
      });
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _impactFxTimer?.cancel();
    _battleLogController.dispose();
    _clashController?.dispose();
    _shakeController?.dispose();
    _victoryController?.dispose();
    _introController?.dispose();
    _statusPulseController?.dispose();
    _impactFxController?.dispose();
    _currentImpactFx = null;
    super.dispose();
  }

  Future<void> _playCinematicIntro() async {
    if (!mounted || _introController == null) {
      return;
    }

    setState(() {
      _showCinematicIntro = true;
    });

    await _introController!.forward(from: 0);

    if (!mounted) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 750));

    if (!mounted) {
      return;
    }

    await _introController!.reverse(from: 1);

    if (!mounted) {
      return;
    }

    setState(() {
      _showCinematicIntro = false;
    });
  }

  Widget _buildRoundLightingOverlay({
    required bool hasStarted,
    required int round,
  }) {
    if (!hasStarted) {
      return const SizedBox.shrink();
    }

    final stage = (round / 8).clamp(0.0, 1.0);

    final topColor = stage < 0.5
        ? Color.lerp(
            const Color(0x4D3379C8),
            const Color(0x26222C44),
            stage * 2,
          )!
        : Color.lerp(
            const Color(0x26222C44),
            const Color(0x4DA03A3A),
            (stage - 0.5) * 2,
          )!;

    final bottomColor = stage < 0.5
        ? Color.lerp(
            const Color(0x4D1C4D8F),
            const Color(0x2610121D),
            stage * 2,
          )!
        : Color.lerp(
            const Color(0x2610121D),
            const Color(0x4D4A1D1D),
            (stage - 0.5) * 2,
          )!;

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[topColor, bottomColor],
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.05,
                colors: <Color>[
                  stage < 0.5
                      ? const Color(0x181E78FF)
                      : const Color(0x18FF6A3D),
                  Colors.transparent,
                ],
                stops: const <double>[0.2, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _heroAuraColor(HeroModel hero) {
    final attackScore = hero.attack * 1.15;
    final defenseScore = hero.defense * 1.25;
    final hpScore = hero.maxHp * 0.9;

    if (hpScore >= attackScore && hpScore >= defenseScore) {
      return const Color(0xFF55D37E);
    }

    if (defenseScore >= attackScore) {
      return const Color(0xFF4C9CFF);
    }

    return const Color(0xFFFF7A45);
  }

  Widget _buildAttackImpactOverlay() {
    final fx = _currentImpactFx;
    if (fx == null || _impactFxController == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _impactFxController!,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(
          _impactFxController!.value,
        );
        final fade = (1 - progress).clamp(0.0, 1.0);
        final intensity = fx.intensity;
        final random = math.Random(fx.seed);
        final sparkCount = 4 + (intensity * 8).round();
        final impactColor = Color.lerp(
          Colors.white,
          const Color(0xFFFFC857),
          intensity,
        )!;
        final hotColor = Color.lerp(
          const Color(0xFFFF5A5A),
          const Color(0xFFFFD166),
          intensity,
        )!;

        return Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: intensity * fade * 0.12,
                    ),
                  ),
                ),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      for (var i = 0; i < 3; i++)
                        Transform.translate(
                          offset: Offset(
                            -56 + (i * 30) + (progress * 26),
                            -20 + (i * 14),
                          ),
                          child: Transform.rotate(
                            angle: -0.72 + (i * 0.14),
                            child: Opacity(
                              opacity:
                                  fade *
                                  (0.72 - (i * 0.14)) *
                                  (0.45 + intensity * 0.55),
                              child: Container(
                                width: 138 + (intensity * 86),
                                height: 6 + (intensity * 3),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: <Color>[
                                      Colors.transparent,
                                      hotColor.withValues(alpha: 0.18),
                                      impactColor.withValues(alpha: 0.95),
                                      hotColor.withValues(alpha: 0.18),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: hotColor.withValues(alpha: 0.42),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      for (var i = 0; i < sparkCount; i++)
                        Builder(
                          builder: (context) {
                            final angle = random.nextDouble() * math.pi * 2;
                            final distance =
                                24 +
                                (random.nextDouble() * (70 + intensity * 50));
                            final sparkProgress = Curves.easeOut.transform(
                              (progress * 1.2 - (i / (sparkCount + 2))).clamp(
                                0.0,
                                1.0,
                              ),
                            );
                            final radius = distance * sparkProgress;
                            final offset = Offset(
                              math.cos(angle) * radius,
                              math.sin(angle) * radius,
                            );
                            final sparkSize =
                                2.0 +
                                (random.nextDouble() * 3.0) +
                                (intensity * 2.2);

                            return Transform.translate(
                              offset: offset,
                              child: Opacity(
                                opacity:
                                    fade *
                                    (0.35 + intensity * 0.65) *
                                    sparkProgress,
                                child: Transform.rotate(
                                  angle: angle,
                                  child: Container(
                                    width: sparkSize,
                                    height: sparkSize * 2.2,
                                    decoration: BoxDecoration(
                                      color: Color.lerp(
                                        Colors.white,
                                        hotColor,
                                        random.nextDouble(),
                                      )!.withValues(alpha: 0.95),
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: hotColor.withValues(
                                            alpha: 0.38,
                                          ),
                                          blurRadius: 8,
                                          spreadRadius: 0.4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamStripCard({
    required HeroModel hero,
    required int hp,
    required int cooldown,
    required int activeIndex,
    required int index,
    required bool alignRight,
    required bool interactive,
    required Color accent,
    required int cooldownDurationSeconds,
    required ValueChanged<int>? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isActive = index == activeIndex;
    final isDown = hp <= 0;
    final canTap =
        interactive && onTap != null && !isDown && !isActive && cooldown <= 0;
    final auraColor = _heroAuraColor(hero);
    final pulseValue = _statusPulseController?.value ?? 0.0;
    final pulse = 0.74 + (math.sin(pulseValue * math.pi * 2) * 0.16);
    final activeGlow = isActive ? pulse : 0.12;
    final grayscale = isDown || cooldown > 0;
    final borderColor = isActive
        ? Color.lerp(accent, Colors.white, 0.25)!
        : theme.colorScheme.outline.withValues(alpha: isDark ? 0.16 : 0.28);

    final imageWidget = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: isActive
                    ? const Alignment(-0.08, -0.18)
                    : const Alignment(0.0, -0.2),
                radius: 1.15,
                colors: <Color>[
                  auraColor.withValues(
                    alpha: isDown ? 0.12 : (isActive ? 0.34 : 0.22),
                  ),
                  Colors.transparent,
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: auraColor.withValues(
                    alpha: isDown ? 0.08 : (isActive ? 0.24 : 0.12),
                  ),
                  blurRadius: isActive ? 28 : 20,
                  spreadRadius: isActive ? 2 : 0,
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: grayscale
                ? const ColorFilter.matrix(<double>[
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ])
                : const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
            child: HeroImage(
              urls: hero.displayImageCandidates,
              heroId: hero.id,
              heroName: hero.name,
              searchTerms: hero.imageSearchTerms,
              fit: BoxFit.cover,
              loading: const ColoredBox(
                color: Color(0xFF221C31),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: const ColoredBox(
                color: Color(0xFF221C31),
                child: Icon(Icons.broken_image, color: Colors.white24),
              ),
            ),
          ),
        ),
        if (isDown)
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
        if (isDown)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CrackedGlassPainter(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ),
          ),
        if (cooldown > 0 && !isDown)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withValues(alpha: 0.06),
                      Colors.black.withValues(alpha: 0.16),
                      Colors.black.withValues(alpha: 0.58),
                    ],
                    stops: const <double>[0.45, 0.72, 1],
                  ),
                ),
              ),
            ),
          ),
        if (isActive)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.18 * activeGlow),
                      blurRadius: 26,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.14 * activeGlow),
                      blurRadius: 12,
                      spreadRadius: 0.6,
                    ),
                  ],
                  border: Border.all(
                    color: accent.withValues(alpha: 0.65 * activeGlow),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(
        left: alignRight ? 10 : 0,
        right: alignRight ? 0 : 10,
      ),
      child: GestureDetector(
        onTap: canTap ? () => onTap(index) : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: isDown ? 0.5 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 100,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xAA171321)
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.9,
                    ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: isActive ? 2 : 1),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: isActive
                      ? accent.withValues(alpha: 0.24 * activeGlow)
                      : Colors.black.withValues(alpha: 0.24),
                  blurRadius: isActive ? 20 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        imageWidget,
                        if (isActive)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    spreadRadius: 0.4,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        if (cooldown > 0 && !isDown)
                          Positioned(
                            top: 7,
                            right: 7,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    value: (cooldown / cooldownDurationSeconds)
                                        .clamp(0.0, 1.0),
                                    strokeWidth: 2.8,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.14,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.redAccent,
                                        ),
                                  ),
                                ),
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.redAccent.withValues(
                                        alpha: 0.88,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '$cooldown',
                                      key: ValueKey<int>(cooldown),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isDown)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.84),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                ),
                              ),
                              child: const Text(
                                'KO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          hero.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDown
                                ? Colors.white.withValues(alpha: 0.75)
                                : (isDark
                                      ? theme.colorScheme.onSurface
                                      : Colors.white.withValues(alpha: 0.94)),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDown
                              ? 'KO'
                              : (cooldown > 0 ? 'Cooldown' : 'HP $hp'),
                          style: TextStyle(
                            color: isDown
                                ? Colors.white.withValues(alpha: 0.58)
                                : (isDark
                                      ? theme.colorScheme.onSurface.withValues(
                                          alpha: 0.72,
                                        )
                                      : Colors.white.withValues(alpha: 0.72)),
                            fontSize: 11,
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
      ),
    );
  }

  Future<List<HeroModel>> _loadAiTeam() async {
    return _api.fetchRandomHeroes(count: 5);
  }

  Future<List<HeroModel>> _loadBanPool() async {
    final pool = await _api.fetchRandomHeroes(count: 20);
    pool.sort((a, b) => _heroScore(b).compareTo(_heroScore(a)));
    return pool;
  }

  int _heroScore(HeroModel hero) {
    return hero.maxHp +
        hero.attack +
        hero.specialAttack +
        hero.defense +
        hero.initiative;
  }

  void _cancelAutoAdvanceTimer({bool resetCountdown = true}) {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
    if (resetCountdown && mounted && _turnCountdown != 0) {
      setState(() {
        _turnCountdown = 0;
      });
    } else if (resetCountdown) {
      _turnCountdown = 0;
    }
  }

  void _scheduleAutoAdvance(BattleProvider provider) {
    _cancelAutoAdvanceTimer(resetCountdown: false);

    if (!mounted ||
        provider.isBattleOver ||
        provider.playerHero == null ||
        provider.aiHero == null) {
      return;
    }

    setState(() {
      _turnCountdown = _autoAdvanceSeconds;
    });

    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final battle = context.read<BattleProvider>();
      if (battle.isBattleOver ||
          battle.playerHero == null ||
          battle.aiHero == null) {
        _cancelAutoAdvanceTimer();
        return;
      }

      if (_isAnimatingTurn) {
        return;
      }

      if (_isResolvingTurn) {
        return;
      }

      if (_turnCountdown <= 1) {
        timer.cancel();
        setState(() {
          _turnCountdown = 0;
        });
        unawaited(_runTurnWithClash(battle));
        return;
      }

      setState(() {
        _turnCountdown--;
      });
    });
  }

  void _autoScrollBattleLogIfNeeded(int currentLogCount) {
    if (currentLogCount == _lastBattleLogCount) {
      return;
    }

    _lastBattleLogCount = currentLogCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_battleLogController.hasClients) {
        return;
      }

      _battleLogController.animateTo(
        _battleLogController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  String _extractRoundFeedback(BattleProvider provider) {
    if (provider.battleLog.isEmpty) return '';

    if (provider.isBattleOver) {
      return provider.playerWon ? 'VICTORY!' : 'DEFEAT';
    }

    final latestLogs = provider.battleLog.length > 10
        ? provider.battleLog.skip(provider.battleLog.length - 10).toList()
        : provider.battleLog;

    for (final log in latestLogs.reversed) {
      if (log.contains('slain') || log.contains('knocked out')) {
        return log;
      }
    }

    final roundPattern = RegExp(r'^Round\s+(\d+):');
    int? latestRound;
    for (final log in latestLogs.reversed) {
      final match = roundPattern.firstMatch(log);
      if (match != null) {
        latestRound = int.tryParse(match.group(1)!);
        break;
      }
    }

    if (latestRound == null) {
      return '';
    }

    String? playerLine;
    String? opponentLine;
    for (final log in latestLogs) {
      if (!log.startsWith('Round $latestRound:')) {
        continue;
      }
      if (log.contains('You dealt')) {
        playerLine ??= log.replaceFirst('Round $latestRound: ', '');
      } else if (log.contains('Opponent dealt')) {
        opponentLine ??= log.replaceFirst('Round $latestRound: ', '');
      }
    }

    if (playerLine != null && opponentLine != null) {
      return 'Round $latestRound: $playerLine  |  $opponentLine';
    }
    return playerLine != null
        ? 'Round $latestRound: $playerLine'
        : (opponentLine != null ? 'Round $latestRound: $opponentLine' : '');
  }

  Color _getFeedbackColor(String feedback, BattleProvider provider) {
    if (feedback.isEmpty) return Colors.transparent;
    if (feedback.contains('VICTORY')) return Colors.greenAccent.shade200;
    if (feedback.contains('DEFEAT')) return Colors.redAccent.shade200;
    if (feedback.contains('You dealt') && feedback.contains('Opponent dealt')) {
      return Colors.amber.shade200;
    }
    if (feedback.contains('You dealt')) return Colors.greenAccent.shade100;
    if (feedback.contains('Opponent dealt')) return Colors.redAccent.shade100;
    return Colors.white;
  }

  Widget _buildRoundFeedbackWidget(String feedback, BattleProvider provider) {
    if (feedback.isEmpty) return const SizedBox.shrink();

    final color = _getFeedbackColor(feedback, provider);
    final isMajor =
        feedback.contains('VICTORY') ||
        feedback.contains('DEFEAT') ||
        feedback.contains('slain') ||
        feedback.contains('knocked out');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isMajor ? 12 : 8),
      child: Text(
        feedback,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: isMajor ? 20 : 16,
          fontWeight: isMajor ? FontWeight.w800 : FontWeight.w600,
          letterSpacing: isMajor ? 0.5 : 0.2,
          shadows: <Shadow>[
            Shadow(
              blurRadius: 12,
              color: Colors.black.withValues(alpha: 0.6),
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runTurnWithClash(BattleProvider provider) async {
    if (_isAnimatingTurn ||
        _isResolvingTurn ||
        provider.isBattleOver ||
        _clashController == null) {
      return;
    }

    _cancelAutoAdvanceTimer();

    setState(() {
      _isAnimatingTurn = true;
      _isResolvingTurn = true;
      _manualNextTurnRequired = false;
    });

    try {
      unawaited(_shakeController?.forward(from: 0));
      unawaited(HapticFeedback.mediumImpact());
      unawaited(SystemSound.play(SystemSoundType.click));
      await _clashController!.forward(from: 0);
      await provider.nextTurn();

      final impactDamage = math.max(
        provider.lastPlayerDamage,
        provider.lastAiDamage,
      );
      if (impactDamage > 0 && mounted) {
        final intensity = (impactDamage / 80).clamp(0.28, 1.0).toDouble();
        _impactFxTimer?.cancel();
        setState(() {
          _currentImpactFx = _BattleImpactFx(
            seed:
                (provider.round * 997) ^
                (provider.lastPlayerDamage * 31) ^
                (provider.lastAiDamage * 17),
            intensity: intensity,
          );
        });
        _impactFxController?.forward(from: 0);
        _impactFxTimer = Timer(const Duration(milliseconds: 820), () {
          if (!mounted) {
            return;
          }
          setState(() {
            _currentImpactFx = null;
          });
          _impactFxController?.reset();
        });
      }

      if (provider.roundWinner != null) {
        await _victoryController?.forward(from: 0);
        _victoryController?.reset();
      }

      if (mounted) {
        setState(() {
          _roundFeedback = _extractRoundFeedback(provider);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnimatingTurn = false;
          _isResolvingTurn = false;
        });
      }

      if (mounted &&
          !provider.isBattleOver &&
          provider.playerHero != null &&
          provider.aiHero != null) {
        _scheduleAutoAdvance(provider);
      }
    }
  }

  Widget _buildAnimatedFighterCard({
    required HeroModel hero,
    required bool isPlayer,
    required bool isRoundWinner,
    required Animation<double> moveAnimation,
    required Animation<double> tiltAnimation,
  }) {
    final victoryAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0, end: -0.05),
            weight: 25,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -0.05, end: 0.05),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.05, end: 0),
            weight: 25,
          ),
        ]).animate(
          CurvedAnimation(parent: _victoryController!, curve: Curves.easeInOut),
        );

    final card = Transform.translate(
      offset: Offset(moveAnimation.value, 0),
      child: Transform.rotate(
        angle: tiltAnimation.value,
        child: BattleHeroCard(hero: hero, isPlayer: isPlayer),
      ),
    );

    if (isRoundWinner) {
      return RotationTransition(turns: victoryAnimation, child: card);
    }

    return card;
  }

  Widget _buildHiddenOpponentCard() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFFE8D6AA) : const Color(0xFF8E6A2A);

    return Card(
      elevation: isDark ? 8 : 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: accent.withValues(alpha: isDark ? 0.5 : 0.38),
          width: 1.6,
        ),
      ),
      child: SizedBox(
        width: 260,
        height: 340,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? <Color>[
                          const Color(0xFF211B33),
                          const Color(0xFF151124),
                          const Color(0xFF0D0B16),
                        ]
                      : <Color>[
                          scheme.surfaceContainerHigh,
                          scheme.surface,
                          scheme.surfaceContainerLow,
                        ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.18 : 0.13),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: accent.withValues(alpha: isDark ? 0.5 : 0.34),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.lock_rounded,
                          size: 14,
                          color: accent.withValues(alpha: 0.95),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'CLASSIFIED',
                          style: TextStyle(
                            color: accent.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent.withValues(alpha: isDark ? 0.35 : 0.24),
                        width: 1.3,
                      ),
                    ),
                    child: Icon(
                      Icons.person_search_rounded,
                      size: 52,
                      color: scheme.onSurface.withValues(alpha: isDark ? 0.85 : 0.72),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'OPPONENT HIDDEN',
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.92),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Text(
                      'Enemy opening hero is concealed until battle initialization.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.66),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiddenOpponentStrip({required bool alignRight}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFFE8D6AA) : const Color(0xFF8E6A2A);
    final titleColor = scheme.onSurface.withValues(alpha: 0.94);
    final secondaryColor = scheme.onSurface.withValues(alpha: 0.72);

    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: alignRight
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Opponent Team',
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '5 cards',
              style: TextStyle(fontSize: 12, color: secondaryColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: 260,
          height: 124,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xAA171321)
                : scheme.surfaceContainerLow.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.34 : 0.24),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.visibility_off_rounded,
                color: secondaryColor,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                'Opponent lineup hidden',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Reveals after Start Battle',
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryColor, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBannedHeroBadge({
    required HeroModel hero,
    required Color accent,
  }) {
    return SizedBox(
      width: 38,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 38,
            height: 38,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ClipOval(
                  child: HeroImage(
                    urls: hero.displayImageCandidates,
                    heroId: hero.id,
                    heroName: hero.name,
                    searchTerms: hero.imageSearchTerms,
                    fit: BoxFit.cover,
                    loading: const ColoredBox(
                      color: Color(0xFF221C31),
                      child: Center(
                        child: SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.4),
                        ),
                      ),
                    ),
                    error: const ColoredBox(
                      color: Color(0xFF221C31),
                      child: Icon(Icons.broken_image, color: Colors.white24),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.78),
                        ],
                      ),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.85),
                        width: 1.1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 1,
                  right: 1,
                  child: Icon(
                    Icons.block_rounded,
                    color: accent,
                    size: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hero.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 7,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarterSelector(List<HeroModel> playerTeam) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: isDark ? 0.08 : 0.72,
    );
    final textColor = theme.colorScheme.onSurface;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List<Widget>.generate(playerTeam.length, (index) {
        final hero = playerTeam[index];
        return ChoiceChip(
          selected: index == _preBattlePlayerIndex,
          label: Text(hero.name),
          onSelected: (_) {
            setState(() {
              _preBattlePlayerIndex = index;
            });
          },
          selectedColor: Colors.blue.withValues(alpha: 0.38),
          backgroundColor: surfaceColor,
          labelStyle: TextStyle(color: textColor),
          side: BorderSide(
            color: index == _preBattlePlayerIndex
                ? Colors.blueAccent
                : theme.colorScheme.outline.withValues(
                    alpha: isDark ? 0.24 : 0.45,
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildTeamStrip({
    required String title,
    required List<HeroModel> heroes,
    required List<int> hpValues,
    required List<int> cooldowns,
    required int activeIndex,
    required Color accent,
    required bool alignRight,
    required bool interactive,
    required int cooldownDurationSeconds,
    required ValueChanged<int>? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryText = isDark
        ? theme.colorScheme.onSurface
        : Colors.white.withValues(alpha: 0.94);
    final secondaryText = isDark
        ? theme.colorScheme.onSurface.withValues(alpha: 0.72)
        : Colors.white.withValues(alpha: 0.72);

    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: alignRight
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                color: primaryText,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${heroes.length} cards',
              style: TextStyle(fontSize: 12, color: secondaryText),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 124,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cards = List<Widget>.generate(heroes.length, (index) {
                final hero = heroes[index];
                final hp = index < hpValues.length ? hpValues[index] : 0;
                final cooldown = index < cooldowns.length
                    ? cooldowns[index]
                    : 0;
                return _buildTeamStripCard(
                  hero: hero,
                  hp: hp,
                  cooldown: cooldown,
                  activeIndex: activeIndex,
                  index: index,
                  alignRight: alignRight,
                  interactive: interactive,
                  accent: accent,
                  cooldownDurationSeconds: cooldownDurationSeconds,
                  onTap: onTap,
                );
              });

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: alignRight
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: cards,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBannedHeroCornerStrip({
    required String label,
    required List<HeroModel> heroes,
    required Color accent,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 4),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              shadows: const <Shadow>[
                Shadow(
                  blurRadius: 6,
                  color: Colors.black,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: heroes
              .map(
                (hero) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _buildBannedHeroBadge(hero: hero, accent: accent),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBannedHeroesTopRow(BattleProvider battle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (battle.playerBanCount > 0)
            _buildBannedHeroCornerStrip(
              label: 'You banned',
              heroes: battle.playerBannedHeroModels,
              accent: const Color(0xFFFF6B6B),
            )
          else
            const SizedBox.shrink(),
          if (battle.aiBanCount > 0)
            _buildBannedHeroCornerStrip(
              label: 'Opponent banned',
              heroes: battle.aiBannedHeroModels,
              accent: const Color(0xFF58A6FF),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildLogEntry(BuildContext context, String log) {
    final textTheme = Theme.of(context).textTheme;
    IconData? icon;
    Color? color;
    TextStyle style = textTheme.bodyMedium!.copyWith(color: Colors.white);

    if (log.contains('You dealt')) {
      icon = Icons.flash_on;
      color = Colors.green;
    } else if (log.contains('Opponent dealt')) {
      icon = Icons.flash_on;
      color = Colors.red;
    } else if (log.contains('won')) {
      icon = Icons.emoji_events;
      color = Colors.amber;
      style = textTheme.titleMedium!.copyWith(
        color: Colors.greenAccent.shade200,
      );
    } else if (log.contains('lost')) {
      icon = Icons.shield;
      color = Colors.red;
      style = textTheme.titleMedium!.copyWith(color: Colors.redAccent.shade200);
    } else if (log.contains('started')) {
      icon = Icons.sports_kabaddi;
      style = textTheme.bodyMedium!.copyWith(
        color: Colors.white70,
        fontStyle: FontStyle.italic,
      );
    } else if (log.contains('switched')) {
      icon = Icons.swap_horiz;
      color = Colors.lightBlueAccent;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        dense: true,
        leading: icon != null ? Icon(icon, color: color, size: 20) : null,
        title: Text(log, style: style),
      ),
    );
  }

  Widget _buildPreBattlePanel({required List<HeroModel> playerTeam}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryText = isDark
        ? theme.colorScheme.onSurface
        : Colors.white.withValues(alpha: 0.94);
    final secondaryText = isDark
        ? theme.colorScheme.onSurface.withValues(alpha: 0.72)
        : Colors.white.withValues(alpha: 0.72);
    final readyText = playerTeam.length == 5
        ? 'Your full 5-card lineup is ready.'
        : 'Choose 5 heroes to start a team battle.';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Battle Briefing',
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(readyText, style: TextStyle(color: secondaryText)),
          const SizedBox(height: 10),
          if (_preBattlePlayerIndex >= 0 &&
              _preBattlePlayerIndex < playerTeam.length)
            Text(
              'Starting Hero: ${playerTeam[_preBattlePlayerIndex].name}',
              style: TextStyle(color: primaryText, fontWeight: FontWeight.w700),
            )
          else
            Text(
              'Starting Hero: (Select one)',
              style: TextStyle(
                color: secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 8),
          _buildStarterSelector(playerTeam),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _buildTeamStrip(
                  title: 'Your Team',
                  heroes: playerTeam,
                  hpValues: playerTeam.map((hero) => hero.maxHp).toList(),
                  cooldowns: const <int>[],
                  activeIndex: _preBattlePlayerIndex,
                  accent: theme.colorScheme.primary,
                  alignRight: false,
                  interactive: true,
                  cooldownDurationSeconds: 6,
                  onTap: (index) {
                    setState(() {
                      _preBattlePlayerIndex = index;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildHiddenOpponentStrip(alignRight: true)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tip: tap your team cards now to choose your opening fighter. Opponent lineup is hidden until battle starts.',
            style: TextStyle(color: secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleLogCard(List<String> logEntries) {
    return Card(
      color: const Color(0xDD13101F),
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.builder(
        controller: _battleLogController,
        padding: const EdgeInsets.all(12),
        itemCount: logEntries.length,
        itemBuilder: (_, i) => _buildLogEntry(context, logEntries[i]),
      ),
    );
  }

  void _resetBattleAndReloadOpponents() {
    context.read<BattleProvider>().reset();
    _cancelAutoAdvanceTimer();
    setState(() {
      _aiTeamFuture = _loadAiTeam();
      _banPoolFuture = _loadBanPool();
      _currentAiTeam = [];
      _winRecorded = false;
      _manualNextTurnRequired = false;
      _isResultOverlayDismissed = false;
      _roundFeedback = '';
      _arenaBackgroundIndex =
          (_arenaBackgroundIndex + 1) % _arenaBackgrounds.length;
    });
    _clashController?.reset();
    _shakeController?.reset();
    _victoryController?.reset();
  }

  Widget _buildBattleResultOverlay(BattleProvider battle) {
    final didPlayerWin = battle.playerWon;
    final accent = didPlayerWin
        ? const Color(0xFF58D37B)
        : const Color(0xFFFF6B6B);
    final panelColor = didPlayerWin
        ? const Color(0xE0142A1A)
        : const Color(0xE02A1414);

    final playerAlive = battle.playerTeamHp.where((hp) => hp > 0).length;
    final aiAlive = battle.aiTeamHp.where((hp) => hp > 0).length;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
          ),
          child: Center(
            child: Container(
              width: 420,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                color: panelColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withValues(alpha: 0.9),
                  width: 2,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _isResultOverlayDismissed = true;
                        });
                      },
                      tooltip: 'Close',
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: _goHome,
                      tooltip: 'Go Home',
                      icon: const Icon(Icons.home_rounded),
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        didPlayerWin ? Icons.emoji_events : Icons.gpp_bad,
                        size: 44,
                        color: accent,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        didPlayerWin ? 'Victory' : 'Defeat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        didPlayerWin
                            ? 'Your team outlasted the opponent squad.'
                            : 'Your full team was knocked out this match.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.84),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Your team alive: $playerAlive',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Enemy alive: $aiAlive',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: <Widget>[
                          FilledButton.icon(
                            onPressed: _resetBattleAndReloadOpponents,
                            icon: const Icon(Icons.refresh),
                            label: const Text('New Battle'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              RouteNames.history,
                            ),
                            icon: const Icon(Icons.history),
                            label: const Text('View History'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckProvider>();
    final battle = context.watch<BattleProvider>();
    final hasBattleStarted = battle.playerHero != null && battle.aiHero != null;

    _autoScrollBattleLogIfNeeded(battle.battleLog.length);

    if (!_isScreenReady) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back to Home',
            onPressed: _goBack,
          ),
          title: const Text('Battle Arena'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (deck.deck.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back to Home',
            onPressed: _goBack,
          ),
          title: const Text('Battle'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Your deck is empty. Add heroes before battling.'),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.deckBuilder),
                  child: const Text('Go to Deck Builder'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_preBattlePlayerIndex >= deck.deck.length) {
      _preBattlePlayerIndex = 0;
    }

    if (battle.isBattleOver && battle.playerWon && !_winRecorded) {
      _winRecorded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        context.read<PlayerProvider>().incrementWins();
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to Home',
          onPressed: _goBack,
        ),
        title: const Text('Battle Arena'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, RouteNames.history),
            tooltip: 'History',
          ),
        ],
      ),
      body: _isInBanningPhase
          ? BanPhaseScreen(
              onBanningComplete: _onBanningPhaseComplete,
            )
          : Stack(
              children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              _arenaBackgrounds[_arenaBackgroundIndex],
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return const ColoredBox(color: Color(0xFF15111F));
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.48),
                  ],
                ),
              ),
            ),
          ),
          _buildRoundLightingOverlay(
            hasStarted: hasBattleStarted,
            round: battle.round,
          ),
          AnimatedBuilder(
            animation: _shakeController!,
            builder: (context, child) {
              final shake = _shakeController!.value;
              final offsetX = math.sin(shake * math.pi * 12) * (1 - shake) * 20;
              return Transform.translate(
                offset: Offset(offsetX, 0),
                child: child,
              );
            },
            child: FutureBuilder<List<HeroModel>>(
              future: _aiTeamFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Center(
                    child: FilledButton.tonal(
                      onPressed: () {
                        setState(() {
                          _aiTeamFuture = _loadAiTeam();
                        });
                      },
                      child: const Text('Retry loading opponent team'),
                    ),
                  );
                }

                final aiTeam = snapshot.data!;
                final battle = context.watch<BattleProvider>();
                final hasStarted =
                    battle.playerHero != null && battle.aiHero != null;
                final playerActiveHero = hasStarted
                    ? battle.playerHero!
                    : deck.deck[_preBattlePlayerIndex];
                final aiActiveHero = hasStarted ? battle.aiHero! : null;
                final canStartBattle =
                    deck.deck.length == 5 &&
                    aiTeam.length == 5 &&
                    !_isAnimatingTurn;

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      if (!hasStarted) ...<Widget>[
                        _BattleGlassPanel(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'Choose 5 heroes and battle as a team.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${deck.deck.length}/5 ready',
                                style: TextStyle(
                                  color: canStartBattle
                                      ? Colors.greenAccent.shade200
                                      : Colors.white70,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (battle.playerBanCount > 0 || battle.aiBanCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _buildBannedHeroesTopRow(battle),
                        ),
                      AnimatedBuilder(
                        animation: Listenable.merge(<Listenable>[
                          _clashController!,
                          _introController!,
                        ]),
                        builder: (context, _) {
                          final move = 80 * _clashProgress!.value;
                          final tilt = 0.12 * _clashProgress!.value;
                          final introProgress =
                              _showCinematicIntro && hasStarted
                              ? Curves.easeOutCubic.transform(
                                  _introController!.value.clamp(0.0, 1.0),
                                )
                              : 1.0;
                          final introLeftOffset = hasStarted
                              ? -320 * (1 - introProgress)
                              : 0.0;
                          final introRightOffset = hasStarted
                              ? 320 * (1 - introProgress)
                              : 0.0;
                          final introLabelProgress =
                              _showCinematicIntro && hasStarted
                              ? ((_introController!.value - 0.18) / 0.82)
                                    .clamp(0.0, 1.0)
                                    .toDouble()
                              : 0.0;

                          return SizedBox(
                            height: 320,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Positioned(
                                  top: 8,
                                  left: 0,
                                  right: 0,
                                  child: _buildRoundFeedbackWidget(
                                    _roundFeedback,
                                    battle,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Transform.translate(
                                    offset: Offset(introLeftOffset, 18),
                                    child: Opacity(
                                      opacity: introProgress,
                                      child: _buildAnimatedFighterCard(
                                        hero: playerActiveHero,
                                        isPlayer: true,
                                        isRoundWinner:
                                            battle.roundWinner ==
                                            playerActiveHero.name,
                                        moveAnimation: Tween<double>(
                                          begin: 0,
                                          end: move,
                                        ).animate(_clashController!),
                                        tiltAnimation: Tween<double>(
                                          begin: 0,
                                          end: tilt,
                                        ).animate(_clashController!),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Transform.translate(
                                    offset: Offset(introRightOffset, 18),
                                    child: hasStarted
                                        ? Opacity(
                                            opacity: introProgress,
                                            child: _buildAnimatedFighterCard(
                                              hero: aiActiveHero!,
                                              isPlayer: false,
                                              isRoundWinner:
                                                  battle.roundWinner ==
                                                  aiActiveHero.name,
                                              moveAnimation: Tween<double>(
                                                begin: 0,
                                                end: -move,
                                              ).animate(_clashController!),
                                              tiltAnimation: Tween<double>(
                                                begin: 0,
                                                end: -tilt,
                                              ).animate(_clashController!),
                                            ),
                                          )
                                        : _buildHiddenOpponentCard(),
                                  ),
                                ),
                                if (_showCinematicIntro && hasStarted)
                                  Positioned(
                                    top: 88,
                                    left: 0,
                                    right: 0,
                                    child: IgnorePointer(
                                      child: Opacity(
                                        opacity: introLabelProgress,
                                        child: Center(
                                          child: Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 360,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.72,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.amber.withValues(
                                                  alpha: 0.9,
                                                ),
                                                width: 2.2,
                                              ),
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.52),
                                                  blurRadius: 22,
                                                  offset: const Offset(0, 10),
                                                ),
                                              ],
                                            ),
                                            child: Transform.scale(
                                              scale:
                                                  0.9 +
                                                  (introLabelProgress * 0.16),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    '${playerActiveHero.name.toUpperCase()}  VS  ${aiActiveHero!.name.toUpperCase()}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      letterSpacing: 1.0,
                                                      shadows: <Shadow>[
                                                        Shadow(
                                                          blurRadius: 16,
                                                          color: Colors.black,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    'BATTLE START',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.amber.shade300,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      letterSpacing: 2.0,
                                                      shadows: const <Shadow>[
                                                        Shadow(
                                                          blurRadius: 12,
                                                          color: Colors.black,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (_showCinematicIntro && hasStarted)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: AnimatedOpacity(
                                        opacity: introLabelProgress * 0.35,
                                        duration: const Duration(
                                          milliseconds: 120,
                                        ),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: <Color>[
                                                Colors.black.withValues(
                                                  alpha: 0.18,
                                                ),
                                                Colors.transparent,
                                                Colors.black.withValues(
                                                  alpha: 0.18,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (!_showCinematicIntro)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      if (battle.round == 0 &&
                                          !_isAnimatingTurn)
                                        const Text(
                                          'VS',
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                            shadows: <Shadow>[
                                              Shadow(
                                                blurRadius: 12,
                                                color: Colors.black,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Opacity(
                                          opacity: _clashFlash!.value,
                                          child: Transform.scale(
                                            scale:
                                                1.0 +
                                                (_clashFlash!.value * 1.8),
                                            child: const Text(
                                              'VS',
                                              style: TextStyle(
                                                fontSize: 48,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber,
                                                shadows: <Shadow>[
                                                  Shadow(
                                                    blurRadius: 12,
                                                    color: Colors.black,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                if (_currentImpactFx != null)
                                  _buildAttackImpactOverlay(),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      if (!(hasStarted && _showCinematicIntro))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: <Widget>[
                              SizedBox(
                                width: 180,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF4B6EFF),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.white24,
                                    disabledForegroundColor: Colors.white54,
                                  ),
                                  onPressed: !hasStarted && canStartBattle
                                      ? () async {
                                          setState(() {
                                            _isPreparingBanPhase = true;
                                          });

                                          try {
                                            _winRecorded = false;
                                            _currentAiTeam = aiTeam;
                                            final provider = context
                                                .read<BattleProvider>();
                                            final banPool =
                                                await (_banPoolFuture ??
                                                    _loadBanPool());
                                            if (!mounted) {
                                              return;
                                            }

                                            provider.startBanningPhase(
                                              playerTeam: deck.deck,
                                              aiTeam: aiTeam,
                                              banPool: <HeroModel>[
                                                ...deck.deck,
                                                ...aiTeam,
                                                ...banPool,
                                              ],
                                            );
                                            setState(() {
                                              _isInBanningPhase = true;
                                            });
                                          } finally {
                                            if (mounted) {
                                              setState(() {
                                                _isPreparingBanPhase = false;
                                              });
                                            }
                                          }
                                        }
                                      : null,
                                  child: const Text('Start Battle'),
                                ),
                              ),
                              if (hasStarted)
                                SizedBox(
                                  width: 180,
                                  child: FilledButton.tonal(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF39435F),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.white24,
                                      disabledForegroundColor: Colors.white54,
                                    ),
                                    onPressed:
                                        !battle.isBattleOver &&
                                            !_isAnimatingTurn
                                        ? () => _runTurnWithClash(
                                            context.read<BattleProvider>(),
                                          )
                                        : null,
                                    child: Text(
                                      _turnCountdown > 0
                                          ? 'Next Turn ($_turnCountdown s)'
                                          : 'Next Turn',
                                    ),
                                  ),
                                ),
                              if (!hasStarted)
                                SizedBox(
                                  width: 180,
                                  child: FilledButton.tonalIcon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF5A3DB8),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.white24,
                                      disabledForegroundColor: Colors.white54,
                                    ),
                                    onPressed: _openDeckBuilder,
                                    icon: const Icon(Icons.style),
                                    label: const Text('Change Deck'),
                                  ),
                                ),
                              if (battle.isBattleOver)
                                SizedBox(
                                  width: 180,
                                  child: FilledButton.tonalIcon(
                                    onPressed: _resetBattleAndReloadOpponents,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('New Battle'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),
                      if (hasStarted && !battle.isBattleOver)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _turnCountdown > 0
                                  ? 'Auto-next in $_turnCountdown s'
                                  : (_manualNextTurnRequired
                                        ? 'Switched hero: tap Next Turn'
                                        : 'Auto-next armed'),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (hasStarted) ...<Widget>[
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: _buildTeamStrip(
                                      title: 'Your Team',
                                      heroes: battle.playerTeam,
                                      hpValues: battle.playerTeamHp,
                                      cooldowns: battle.playerSwitchCooldowns,
                                      activeIndex: battle.playerActiveIndex,
                                      accent: Colors.greenAccent,
                                      alignRight: false,
                                      interactive:
                                          !_isAnimatingTurn &&
                                          !battle.isBattleOver,
                                      cooldownDurationSeconds:
                                          battle.switchCooldownDurationSeconds,
                                      onTap: (index) {
                                        final provider = context
                                            .read<BattleProvider>();
                                        final switched = provider
                                            .switchPlayerHero(index);
                                        if (switched) {
                                          setState(() {
                                            _manualNextTurnRequired = true;
                                          });
                                          _scheduleAutoAdvance(provider);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTeamStrip(
                                      title: 'Opponent Team',
                                      heroes: battle.aiTeam,
                                      hpValues: battle.aiTeamHp,
                                      cooldowns: battle.aiSwitchCooldowns,
                                      activeIndex: battle.aiActiveIndex,
                                      accent: Colors.redAccent,
                                      alignRight: true,
                                      interactive: false,
                                      cooldownDurationSeconds:
                                          battle.switchCooldownDurationSeconds,
                                      onTap: null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _BattleGlassPanel(
                                child: HpBar(
                                  label: battle.playerHero!.name,
                                  current: battle.playerHp,
                                  max: battle.playerHero!.maxHp,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _BattleGlassPanel(
                                child: HpBar(
                                  label: battle.aiHero!.name,
                                  current: battle.aiHp,
                                  max: battle.aiHero!.maxHp,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 220,
                                child: _buildBattleLogCard(battle.battleLog),
                              ),
                            ],
                          ),
                        ),
                      ] else ...<Widget>[
                        Expanded(
                          child: _BattleGlassPanel(
                            child: _buildPreBattlePanel(playerTeam: deck.deck),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          if (battle.isBattleOver && !_isResultOverlayDismissed)
            _buildBattleResultOverlay(battle),
          if (_isPreparingBanPhase)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.72),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF17122A).withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFB56DFF).withValues(alpha: 0.85),
                          width: 1.4,
                        ),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0xAA000000),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const SizedBox(
                            width: 34,
                            height: 34,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Preparing banning phase...',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Loading stronger heroes and matchup pool',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.68),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
              ),
    );
  }
}

class _BattleGlassPanel extends StatelessWidget {
  const _BattleGlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xA0151121),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BattleImpactFx {
  const _BattleImpactFx({required this.seed, required this.intensity});

  final int seed;
  final double intensity;
}

class _CrackedGlassPainter extends CustomPainter {
  _CrackedGlassPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.48);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round;

    final shards = <List<Offset>>[
      <Offset>[
        center,
        Offset(size.width * 0.22, size.height * 0.14),
        Offset(size.width * 0.12, size.height * 0.04),
      ],
      <Offset>[
        center,
        Offset(size.width * 0.72, size.height * 0.12),
        Offset(size.width * 0.9, size.height * 0.06),
      ],
      <Offset>[
        center,
        Offset(size.width * 0.84, size.height * 0.46),
        Offset(size.width * 0.96, size.height * 0.28),
      ],
      <Offset>[
        center,
        Offset(size.width * 0.72, size.height * 0.84),
        Offset(size.width * 0.9, size.height * 0.94),
      ],
      <Offset>[
        center,
        Offset(size.width * 0.28, size.height * 0.88),
        Offset(size.width * 0.08, size.height * 0.92),
      ],
      <Offset>[
        center,
        Offset(size.width * 0.12, size.height * 0.48),
        Offset(size.width * 0.04, size.height * 0.3),
      ],
    ];

    for (final points in shards) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        final point = points[i];
        final previous = points[i - 1];
        final mid = Offset(
          (previous.dx + point.dx) / 2,
          (previous.dy + point.dy) / 2,
        );
        path.quadraticBezierTo(mid.dx, mid.dy, point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }

    final crackGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, size.shortestSide * 0.08, crackGlow);
  }

  @override
  bool shouldRepaint(covariant _CrackedGlassPainter oldDelegate) =>
      oldDelegate.color != color;
}
