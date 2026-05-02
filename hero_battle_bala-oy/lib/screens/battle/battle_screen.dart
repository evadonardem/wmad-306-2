import 'dart:async';
import 'dart:math';

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
import '../../widgets/hp_bar.dart';

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

  HeroModel? _selectedPlayerHero;
  Future<HeroModel>? _aiFuture;
  AnimationController? _clashController;
  AnimationController? _shakeController;
  AnimationController? _victoryController;
  AnimationController? _particleController;
  Animation<double>? _clashProgress;
  Animation<double>? _clashFlash;
  Animation<double>? _particleProgress;
  Animation<double>? _victoryGlow;
  final ScrollController _battleLogController = ScrollController();
  int _lastBattleLogCount = 0;
  bool _isAnimatingTurn = false;
  bool _winRecorded = false;
  bool _isScreenReady = false;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Defer all heavy initialization until after the first frame.
      final clashController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
      final shakeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 420),
      );
      final victoryController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );

      setState(() {
        _clashController = clashController;
        _shakeController = shakeController;
        _victoryController = victoryController;
        _clashProgress = TweenSequence<double>([
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
        ]).animate(clashController);
        _clashFlash = CurvedAnimation(
          parent: clashController,
          curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
        );

        final particleController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 420),
        );

        _particleController = particleController;
        _particleProgress = CurvedAnimation(
          parent: particleController,
          curve: Curves.easeOut,
        );
        _victoryGlow = Tween<double>(begin: 1.0, end: 1.08).animate(
          CurvedAnimation(parent: victoryController, curve: Curves.easeInOut),
        );

        context.read<BattleProvider>().reset();
        _aiFuture = _loadAiHero();
        _isScreenReady = true;
      });
    });
  }

  @override
  void dispose() {
    _battleLogController.dispose();
    _clashController?.dispose();
    _shakeController?.dispose();
    _particleController?.dispose();
    _victoryController?.dispose();
    super.dispose();
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

      final maxExtent = _battleLogController.position.maxScrollExtent;
      _battleLogController.animateTo(
        maxExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<HeroModel> _loadAiHero() async {
    return _api.fetchRandomHeroFast();
  }

  Future<void> _runTurnWithClash(BattleProvider provider) async {
    if (_isAnimatingTurn || provider.isBattleOver || _clashController == null) {
      return;
    }

    setState(() {
      _isAnimatingTurn = true;
    });

    try {
      unawaited(_particleController?.forward(from: 0));
      unawaited(_shakeController?.forward(from: 0));
      // Quick impact cue that works on desktop/mobile without extra assets.
      unawaited(HapticFeedback.mediumImpact());
      unawaited(SystemSound.play(SystemSoundType.click));
      await _clashController!.forward(from: 0);
      await provider.nextTurn();

      if (provider.roundWinner != null) {
        await _victoryController?.forward(from: 0);
        _victoryController?.reset();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnimatingTurn = false;
        });
      }
    }
  }

  Widget _buildAnimatedFighterCard({
    required HeroModel hero,
    required bool isPlayer,
    required bool isRoundWinner,
    required Animation<double> moveAnimation,
    required Animation<double> tiltAnimation,
    int? damageTaken,
    bool isCritical = false,
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
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective
          ..rotateY(tiltAnimation.value * 0.5) // 3D rotation
          ..rotateX(tiltAnimation.value * 0.2),
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: tiltAnimation.value,
          child: BattleHeroCard(hero: hero, isPlayer: isPlayer),
        ),
      ),
    );

    final effectCard = Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        if (damageTaken != null)
          Positioned(
            top: -14,
            left: isPlayer ? 0 : null,
            right: isPlayer ? null : 0,
            child: AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 260),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      isPlayer ? Colors.redAccent : Colors.orangeAccent,
                      Colors.black.withAlpha(200),
                    ],
                    radius: 1.4,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCritical ? Icons.whatshot : Icons.health_and_safety,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '-$damageTaken',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (isCritical)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text(
                          'CRIT!',
                          style: TextStyle(
                            color: Colors.yellowAccent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    if (isRoundWinner) {
      return ScaleTransition(
        scale: _victoryGlow ?? AlwaysStoppedAnimation(1),
        child: RotationTransition(turns: victoryAnimation, child: effectCard),
      );
    }

    return effectCard;
  }

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckProvider>();
    final battle = context.watch<BattleProvider>();

    _autoScrollBattleLogIfNeeded(battle.battleLog.length);

    if (!_isScreenReady) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
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
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
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

    _selectedPlayerHero ??= deck.deck.first;
    if (!deck.deck.any((h) => h.id == _selectedPlayerHero!.id)) {
      _selectedPlayerHero = deck.deck.first;
    }

    final hasStarted = battle.playerHero != null && battle.aiHero != null;

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
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
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
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: ColoredBox(color: Color(0xFF15111F)),
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
          AnimatedBuilder(
            animation: _shakeController!,
            builder: (context, child) {
              final shake = _shakeController!.value;
              final offsetX = sin(shake * pi * 12) * (1 - shake) * 20;
              return Transform.translate(
                offset: Offset(offsetX, 0),
                child: child,
              );
            },
            child: FutureBuilder<HeroModel>(
              future: _aiFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: FilledButton.tonal(
                      onPressed: () =>
                          setState(() => _aiFuture = _loadAiHero()),
                      child: const Text('Retry loading opponent'),
                    ),
                  );
                }

                final aiHero = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      _BattleGlassPanel(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                        child: DropdownButtonFormField<HeroModel>(
                          dropdownColor: const Color(0xFF181327),
                          style: const TextStyle(color: Colors.white),
                          initialValue: _selectedPlayerHero,
                          items: deck.deck
                              .map(
                                (h) => DropdownMenuItem<HeroModel>(
                                  value: h,
                                  child: Text(
                                    h.name,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedPlayerHero = value);
                                      if (battle.round > 0 && battle.playerHero != null) {
                                        // Switch hero during battle
                                        final oldHp = battle.playerHp;
                                        final oldMaxHp = battle.playerHero!.maxHp;
                                        final newMaxHp = value.maxHp;
                                        final newHp = ((oldHp / oldMaxHp) * newMaxHp).round().clamp(1, newMaxHp);
                                        context.read<BattleProvider>().switchHero(value, newHp);
                                      }
                                    }
                                  },
                          iconEnabledColor: Colors.white,
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Your hero',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _BattleGlassPanel(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Text(
                          'Opponent: ${aiHero.name}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: <Shadow>[
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black87,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _BattleGlassPanel(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_selectedPlayerHero!.name} Storyline',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _selectedPlayerHero!.storyline,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _BattleGlassPanel(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${aiHero.name} Storyline',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    aiHero.storyline,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _clashController!,
                          builder: (context, _) {
                            final move = 80 * _clashProgress!.value;
                            final tilt = 0.12 * _clashProgress!.value;

                            return Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _buildAnimatedFighterCard(
                                    hero:
                                        battle.playerHero ??
                                        _selectedPlayerHero!,
                                    isPlayer: true,
                                    isRoundWinner:
                                        battle.roundWinner ==
                                        (battle.playerHero ??
                                                _selectedPlayerHero!)
                                            .name,
                                    moveAnimation: Tween<double>(
                                      begin: 0,
                                      end: move,
                                    ).animate(_clashController!),
                                    tiltAnimation: Tween<double>(
                                      begin: 0,
                                      end: tilt,
                                    ).animate(_clashController!),
                                    damageTaken: battle.lastAiDamage,
                                    isCritical: battle.aiCritical,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _buildAnimatedFighterCard(
                                    hero: aiHero,
                                    isPlayer: false,
                                    isRoundWinner:
                                        battle.roundWinner == aiHero.name,
                                    moveAnimation: Tween<double>(
                                      begin: 0,
                                      end: -move,
                                    ).animate(_clashController!),
                                    tiltAnimation: Tween<double>(
                                      begin: 0,
                                      end: -tilt,
                                    ).animate(_clashController!),
                                    damageTaken: battle.lastPlayerDamage,
                                    isCritical: battle.playerCritical,
                                  ),
                                ),
                                if (_particleProgress != null)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: CustomPaint(
                                        painter: _BattleParticlePainter(
                                          _particleProgress!.value,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (battle.round == 0 && !_isAnimatingTurn)
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
                                      scale: 1.0 + (_clashFlash!.value * 1.8),
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
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (hasStarted && battle.round > 0) ...<Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _buildDamageSummary(battle),
                        ),
                        const SizedBox(height: 6),
                        if (battle.isBattleOver)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _buildBattleResultBanner(battle),
                          ),
                      ],
                      _BattleGlassPanel(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF4B6EFF),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.white24,
                                  disabledForegroundColor: Colors.white54,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onPressed: !hasStarted && !_isAnimatingTurn
                                    ? () async {
                                        _winRecorded = false;
                                        final provider = context
                                            .read<BattleProvider>();
                                        provider.startBattle(
                                          playerHero: _selectedPlayerHero!,
                                          aiHero: aiHero,
                                        );
                                        await _runTurnWithClash(provider);
                                      }
                                    : null,
                                child: const Text('Start Battle', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.tonal(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF39435F),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.white24,
                                  disabledForegroundColor: Colors.white54,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onPressed:
                                    hasStarted &&
                                        !battle.isBattleOver &&
                                        !_isAnimatingTurn
                                    ? () => _runTurnWithClash(
                                        context.read<BattleProvider>(),
                                      )
                                    : null,
                                child: const Text('Next Turn', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (hasStarted) ...<Widget>[
                        _BattleGlassPanel(
                          child: HpBar(
                            label: battle.playerHero!.name,
                            current: battle.playerHp,
                            max: battle.playerHero!.maxHp,
                            color: Colors.green,
                            currentMana: battle.playerMana,
                            maxMana: battle.playerHero!.maxMana,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _BattleGlassPanel(
                          child: HpBar(
                            label: aiHero.name,
                            current: battle.aiHp,
                            max: aiHero.maxHp,
                            color: Colors.red,
                            currentMana: battle.aiMana,
                            maxMana: aiHero.maxMana,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Column(
                            children: [
                              _buildSkillSelector(battle),
                              const SizedBox(height: 6),
                              if (battle.isBattleOver)
                                FilledButton.tonalIcon(
                                  onPressed: () {
                                    context.read<BattleProvider>().reset();
                                    setState(() {
                                      _aiFuture = _loadAiHero();
                                    });
                                    _clashController?.reset();
                                    _shakeController?.reset();
                                    _victoryController?.reset();
                                  },
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('New Battle', style: TextStyle(fontSize: 11)),
                                ),
                              if (!battle.isBattleOver)
                                const SizedBox(height: 0),
                              const SizedBox(height: 6),
                              Expanded(
                                child: Card(
                                  color: const Color(0xDD13101F),
                                  elevation: 4,
                                  margin: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.builder(
                                    controller: _battleLogController,
                                    padding: const EdgeInsets.all(8),
                                    itemCount: battle.battleLog.length,
                                    itemBuilder: (_, i) {
                                      return _buildLogEntry(
                                        context,
                                        battle.battleLog[i],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...<Widget>[
                        Expanded(
                          child: _BattleGlassPanel(
                            child: _buildPreBattlePanel(
                              playerHero: _selectedPlayerHero!,
                              aiHero: aiHero,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(BuildContext context, String log) {
    final textTheme = Theme.of(context).textTheme;
    final battle = context.read<BattleProvider>();

    IconData? icon;
    Color? color;
    TextStyle style = textTheme.bodyMedium!.copyWith(color: Colors.white);

    if (log.contains('dealt')) {
      icon = Icons.flash_on;
      color = log.contains(battle.playerHero?.name ?? '')
          ? Colors.greenAccent.shade200
          : Colors.redAccent.shade200;
    } else if (log.contains('Damage taken')) {
      icon = Icons.health_and_safety;
      color = Colors.orangeAccent.shade200;
      style = textTheme.bodyMedium!.copyWith(
        color: Colors.orangeAccent.shade100,
      );
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
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        dense: true,
        leading: icon != null ? Icon(icon, color: color, size: 20) : null,
        title: Text(log, style: style),
      ),
    );
  }

  Widget _buildDamageSummary(BattleProvider battle) {
    if (battle.lastPlayerDamage == null || battle.lastAiDamage == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xAA1F1F29),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'You took',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
                Text(
                  '-${battle.lastAiDamage}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.redAccent.shade200,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (battle.aiCritical)
                  Text(
                    'Enemy critical hit!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.yellowAccent.shade100,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xAA1F1F29),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Enemy took',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
                Text(
                  '-${battle.lastPlayerDamage}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.lightGreenAccent.shade200,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (battle.playerCritical)
                  Text(
                    'You landed a critical!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.greenAccent.shade100,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBattleResultBanner(BattleProvider battle) {
    final title = battle.playerWon ? 'VICTORY!' : 'DEFEAT';
    final message = battle.playerWon
        ? 'Your hero survived and won the fight.'
        : 'The opponent won this battle. Try again with a stronger lineup.';
    final bannerColor = battle.playerWon
        ? Colors.greenAccent.shade400
        : Colors.redAccent.shade400;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                battle.playerWon ? Icons.emoji_events : Icons.cancel,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${battle.round} rounds completed',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreBattlePanel({
    required HeroModel playerHero,
    required HeroModel aiHero,
  }) {
    const labelStyle = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Battle Briefing',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Matchup preview before Round 1 starts',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 14),
        _buildStatComparisonRow(
          label: 'HP',
          playerValue: playerHero.maxHp,
          aiValue: aiHero.maxHp,
          labelStyle: labelStyle,
        ),
        _buildStatComparisonRow(
          label: 'Attack',
          playerValue: playerHero.attack,
          aiValue: aiHero.attack,
          labelStyle: labelStyle,
        ),
        _buildStatComparisonRow(
          label: 'Special',
          playerValue: playerHero.specialAttack,
          aiValue: aiHero.specialAttack,
          labelStyle: labelStyle,
        ),
        _buildStatComparisonRow(
          label: 'Initiative',
          playerValue: playerHero.initiative,
          aiValue: aiHero.initiative,
          labelStyle: labelStyle,
        ),
        const Divider(color: Colors.white24, height: 24),
        const Text(
          'Tip: choose a hero with balanced HP and initiative for a safer opening turn.',
          style: TextStyle(color: Colors.white70),
        ),
        const Spacer(),
        const Text(
          'Press Start Battle to begin the turn log and HP tracking.',
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildStatComparisonRow({
    required String label,
    required int playerValue,
    required int aiValue,
    required TextStyle labelStyle,
  }) {
    final bool playerLeads = playerValue > aiValue;
    final bool aiLeads = aiValue > playerValue;

    Color playerColor = Colors.white;
    Color aiColor = Colors.white;
    if (playerLeads) {
      playerColor = Colors.greenAccent.shade200;
      aiColor = Colors.redAccent.shade100;
    } else if (aiLeads) {
      playerColor = Colors.redAccent.shade100;
      aiColor = Colors.greenAccent.shade200;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          SizedBox(width: 84, child: Text(label, style: labelStyle)),
          Expanded(
            child: Text(
              '$playerValue',
              textAlign: TextAlign.left,
              style: TextStyle(color: playerColor, fontWeight: FontWeight.w700),
            ),
          ),
          const Text('vs', style: TextStyle(color: Colors.white54)),
          Expanded(
            child: Text(
              '$aiValue',
              textAlign: TextAlign.right,
              style: TextStyle(color: aiColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillSelector(BattleProvider battle) {
    if (battle.playerHero == null) {
      return const SizedBox.shrink();
    }

    final skills = battle.playerHero!.skills;
    final selectedSkill = battle.selectedSkill;
    final mana = battle.playerMana;
    final maxMana = battle.playerHero!.maxMana;

    return _BattleGlassPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Skill',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                'Mana: $mana/$maxMana',
                style: TextStyle(
                  color: Colors.cyanAccent.shade200,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: skills.length,
              itemBuilder: (_, idx) {
                final skill = skills[idx];
                final canUse = skill.manaCost <= mana;
                final isSelected = selectedSkill?.id == skill.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: canUse
                        ? () => context.read<BattleProvider>().selectSkill(skill)
                        : null,
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.purpleAccent.withAlpha(100)
                            : canUse
                                ? const Color(0xFF2A2A3E)
                                : const Color(0xFF1A1A2E),
                        border: Border.all(
                          color: isSelected
                              ? Colors.purpleAccent
                              : canUse
                                  ? Colors.white30
                                  : Colors.white10,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              skill.name,
                              style: TextStyle(
                                color: canUse
                                    ? Colors.white
                                    : Colors.white54,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Cost: ${skill.manaCost}',
                              style: TextStyle(
                                color: canUse
                                    ? Colors.cyanAccent.shade200
                                    : Colors.red.shade300,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Pow: +${skill.power}',
                              style: const TextStyle(
                                color: Colors.yellowAccent,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedSkill != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(6),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withAlpha(80),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Ready: ${selectedSkill.name} (${selectedSkill.manaCost} mana)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
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

class _BattleParticlePainter extends CustomPainter {
  final double progress;

  const _BattleParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) {
      return;
    }

    final center = size.center(Offset.zero);
    const baseRadius = 90.0;
    final paint = Paint()..style = PaintingStyle.fill;
    final eased = Curves.easeOut.transform(progress);

    for (var i = 0; i < 12; i++) {
      final angle = (2 * pi / 12) * i + eased * 1.4;
      final factor = eased * (0.7 + (i % 3) * 0.1);
      final distance = 24 + (baseRadius - 24) * factor;
      final radius = 3 + (i % 3) * 1.5;
      paint.color = Colors.amberAccent.withAlpha(
        ((1 - eased) * 100).round() + ((i % 2) * 20),
      );
      final offset = Offset(cos(angle), sin(angle)) * distance;
      canvas.drawCircle(center + offset, radius, paint);
    }

    for (var i = 0; i < 6; i++) {
      final angle = (2 * pi / 6) * i - eased * 0.8;
      final length = 40 + (baseRadius + 20 - 40) * eased;
      paint
        ..color = Colors.white.withAlpha(((1 - eased) * 60).round())
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        center + Offset(cos(angle), sin(angle)) * 10,
        center + Offset(cos(angle), sin(angle)) * length,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BattleParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
