import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../services/database_service.dart';
import '../../services/superhero_api_service.dart';
import '../../providers/deck_provider.dart';
import '../../providers/battle_history_provider.dart';

class ActionCard {
  final String id;
  final String name;
  final String description;
  final int energyCost;
  final int damage;
  final String type; // 'attack', 'skill', 'defend', 'heal'
  final String? specialEffect;

  ActionCard({
    required this.id,
    required this.name,
    required this.description,
    required this.energyCost,
    required this.damage,
    required this.type,
    this.specialEffect,
  });
}

class RoundResult {
  final HeroModel playerHero;
  final HeroModel aiHero;
  final String winner;
  final int roundNumber;

  RoundResult({
    required this.playerHero,
    required this.aiHero,
    required this.winner,
    required this.roundNumber,
  });
}

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with TickerProviderStateMixin {
  bool _isBattling = false;
  bool _battleComplete = false;
  bool _roundInProgress = false;
  String? _winner;
  int _playerScore = 0;
  int _aiScore = 0;
  int _currentRound = 1;
  List<HeroModel> _aiDeck = [];
  List<RoundResult> _roundResults = [];
  List<HeroModel> _usedPlayerHeroes = [];
  HeroModel? _selectedPlayerHero;
  HeroModel? _currentAiHero;

  // Tactical Battle System
  int _playerCurrentHp = 0;
  int _playerMaxHp = 0;
  int _aiCurrentHp = 0;
  int _aiMaxHp = 0;
  List<String> _battleLog = [];
  bool _isPlayerTurn = true;

  // Enhanced Stats
  int _playerAttack = 0;
  int _playerDefense = 0;
  int _playerSpeed = 0;
  int _aiAttack = 0;
  int _aiDefense = 0;
  int _aiSpeed = 0;

  // Energy System
  int _playerEnergy = 3;
  int _maxEnergy = 3;

  // Action Cards System
  List<ActionCard> _playerActionDeck = [];
  List<ActionCard> _playerHand = [];
  ActionCard? _selectedActionCard;

  // Hero Management
  List<HeroModel> _playerActiveHeroes = [];
  HeroModel? _playerActiveHero;
  HeroModel? _aiActiveHero;

  // Hero HP State Management
  Map<String, int> _playerHeroHp = {}; // Track HP for all player heroes
  Map<String, int> _aiHeroHp = {}; // Track HP for all AI heroes

  // Swap State
  bool _showForceSwapDialog = false;
  bool _showManualSwapDialog = false;
  bool _isSwapping = false;

  // Combat Animation State
  bool _isPlayerLunging = false;
  bool _isAiLunging = false;
  bool _showHitFlash = false;
  bool _showCriticalHit = false;
  bool _isPlayerShaking = false;
  bool _isAiShaking = false;
  double _targetPlayerHp = 0;
  double _targetAiHp = 0;

  // Battle States
  bool _showActionMenu = false;
  bool _heroDefeated = false;
  bool _battleEnded = false;

  // Scroll Controller for Battle Briefing
  final ScrollController _battleLogScrollController = ScrollController();

  late AnimationController _animationController;
  late AnimationController _vsAnimationController;
  late AnimationController _collisionAnimationController;
  late AnimationController _shakeAnimationController;
  late AnimationController _clashAnimationController;

  // Combat Animation Controllers
  late AnimationController _lungeAnimationController;
  late AnimationController _damageShakeController;
  late AnimationController _healthBarAnimationController;
  late AnimationController _turnIndicatorController;
  late AnimationController _hitFlashController;
  late AnimationController _criticalHitController;

  late Animation<double> _scaleAnimation;
  late Animation<Offset> _vsSlideAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _clashAnimation;

  // Combat Animations
  late Animation<Offset> _lungeAnimation;
  late Animation<double> _damageShakeAnimation;
  late Animation<double> _healthBarAnimation;
  late Animation<double> _turnIndicatorAnimation;
  late Animation<double> _hitFlashAnimation;
  late Animation<double> _criticalHitAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _vsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _collisionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _clashAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize combat animation controllers
    _lungeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _damageShakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _healthBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _turnIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _hitFlashController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _criticalHitController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(_animationController);
    _vsSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _vsAnimationController,
            curve: Curves.elasticOut,
          ),
        );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeAnimationController,
        curve: Curves.elasticIn,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _collisionAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _clashAnimation =
        Tween<Offset>(
          begin: const Offset(-0.3, 0),
          end: const Offset(0.3, 0),
        ).animate(
          CurvedAnimation(
            parent: _clashAnimationController,
            curve: Curves.elasticOut,
          ),
        );

    // Initialize combat animations
    _lungeAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.3, 0), // Lunge toward center
        ).animate(
          CurvedAnimation(
            parent: _lungeAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    _damageShakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _damageShakeController, curve: Curves.elasticIn),
    );

    _healthBarAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _healthBarAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _turnIndicatorAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _turnIndicatorController,
        curve: Curves.elasticInOut,
      ),
    );

    _hitFlashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hitFlashController, curve: Curves.easeInOut),
    );

    _criticalHitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _criticalHitController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _vsAnimationController.dispose();
    _collisionAnimationController.dispose();
    _shakeAnimationController.dispose();
    _clashAnimationController.dispose();

    // Dispose combat animation controllers
    _lungeAnimationController.dispose();
    _damageShakeController.dispose();
    _healthBarAnimationController.dispose();
    _turnIndicatorController.dispose();
    _hitFlashController.dispose();
    _criticalHitController.dispose();

    super.dispose();
  }

  Future<void> _startBattle() async {
    if (_isBattling) return;

    // Generate AI deck
    _aiDeck = await SuperheroApiService().fetchRandomHeroes(count: 5);

    // Get player deck
    final deckProvider = context.read<DeckProvider>();
    final playerDeck = deckProvider.deck;

    // Initialize tactical battle system
    _initializeTacticalBattle(playerDeck);

    setState(() {
      _isBattling = true;
      _battleComplete = false;
      _winner = null;
      _playerScore = 0;
      _aiScore = 0;
      _currentRound = 1;
      _roundResults = [];
      _battleLog = [];
      _battleEnded = false;
      _heroDefeated = false;
      _showActionMenu = false;
    });

    _addToBattleLog('=== TACTICAL BATTLE BEGINS ===');
    _addToBattleLog('Heroes deployed to the arena!');
  }

  void _initializeTacticalBattle(List<HeroModel> playerDeck) {
    // Set up player heroes
    _playerActiveHeroes = List.from(playerDeck);
    _playerActiveHero = _playerActiveHeroes.isNotEmpty
        ? _playerActiveHeroes.first
        : null;

    // Set up AI heroes
    _aiActiveHero = _aiDeck.isNotEmpty ? _aiDeck.first : null;

    // Initialize HP tracking for all heroes
    _initializeHeroHpTracking(playerDeck, _aiDeck);

    // Initialize action deck based on active hero
    if (_playerActiveHero != null) {
      _playerActionDeck = _generateActionDeck(_playerActiveHero!);
      _playerHand = _drawInitialHand();
    }

    // Reset energy
    _playerEnergy = _maxEnergy;

    // Determine turn order based on speed
    if (_playerActiveHero != null && _aiActiveHero != null) {
      _initializeHeroStats();
      _isPlayerTurn = _playerSpeed >= _aiSpeed;
      _addToBattleLog(
        '${_isPlayerTurn ? _playerActiveHero!.name : _aiActiveHero!.name} attacks first!',
      );

      // Start the first turn
      _startNewTurn();
    }
  }

  void _initializeHeroHpTracking(
    List<HeroModel> playerDeck,
    List<HeroModel> aiDeck,
  ) {
    // Initialize HP for all player heroes
    _playerHeroHp.clear();
    for (final hero in playerDeck) {
      final maxHp = (hero.powerStats.durability * 2) + 50;
      _playerHeroHp[hero.name] = maxHp;
    }

    // Initialize HP for all AI heroes
    _aiHeroHp.clear();
    for (final hero in aiDeck) {
      final maxHp = (hero.powerStats.durability * 2) + 50;
      _aiHeroHp[hero.name] = maxHp;
    }

    _addToBattleLog('HP initialized for all heroes');
  }

  void _initializeHeroStats() {
    if (_playerActiveHero != null) {
      _playerMaxHp = (_playerActiveHero!.powerStats.durability * 2) + 50;
      _playerCurrentHp = _playerHeroHp[_playerActiveHero!.name] ?? _playerMaxHp;
      _playerAttack = _playerActiveHero!.powerStats.strength;
      _playerDefense = _playerActiveHero!.powerStats.durability ~/ 2;
      _playerSpeed = _playerActiveHero!.powerStats.speed;
    }

    if (_aiActiveHero != null) {
      _aiMaxHp = (_aiActiveHero!.powerStats.durability * 2) + 50;
      _aiCurrentHp = _aiHeroHp[_aiActiveHero!.name] ?? _aiMaxHp;
      _aiAttack = _aiActiveHero!.powerStats.strength;
      _aiDefense = _aiActiveHero!.powerStats.durability ~/ 2;
      _aiSpeed = _aiActiveHero!.powerStats.speed;
    }
  }

  List<ActionCard> _generateActionDeck(HeroModel hero) {
    List<ActionCard> deck = [];

    // Basic attack cards
    deck.add(
      ActionCard(
        id: 'basic_attack',
        name: 'Basic Attack',
        description: 'A standard attack dealing moderate damage.',
        energyCost: 1,
        damage: _playerAttack ~/ 2,
        type: 'attack',
      ),
    );

    // Hero-specific skill cards based on their powers
    if (hero.powerStats.intelligence > 80) {
      deck.add(
        ActionCard(
          id: 'tactical_strike',
          name: 'Tactical Strike',
          description: 'A precise attack that ignores some defense.',
          energyCost: 2,
          damage: (_playerAttack * 0.8).round(),
          type: 'skill',
          specialEffect: 'ignore_defense',
        ),
      );
    }

    if (hero.powerStats.speed > 80) {
      deck.add(
        ActionCard(
          id: 'swift_strike',
          name: 'Swift Strike',
          description: 'A fast attack that costs less energy.',
          energyCost: 1,
          damage: (_playerAttack * 0.6).round(),
          type: 'skill',
          specialEffect: 'low_cost',
        ),
      );
    }

    if (hero.powerStats.strength > 80) {
      deck.add(
        ActionCard(
          id: 'power_slam',
          name: 'Power Slam',
          description: 'A devastating attack using raw strength.',
          energyCost: 3,
          damage: _playerAttack,
          type: 'skill',
          specialEffect: 'high_damage',
        ),
      );
    }

    // Defense cards
    deck.add(
      ActionCard(
        id: 'defend',
        name: 'Defend',
        description: 'Raise your guard to reduce incoming damage.',
        energyCost: 1,
        damage: 0,
        type: 'defend',
        specialEffect: 'reduce_damage',
      ),
    );

    // Add multiple copies of basic cards
    for (int i = 0; i < 2; i++) {
      deck.add(
        ActionCard(
          id: 'basic_attack_$i',
          name: 'Basic Attack',
          description: 'A standard attack dealing moderate damage.',
          energyCost: 1,
          damage: _playerAttack ~/ 2,
          type: 'attack',
        ),
      );
    }

    return deck;
  }

  List<ActionCard> _drawInitialHand() {
    List<ActionCard> hand = [];
    for (int i = 0; i < 3 && i < _playerActionDeck.length; i++) {
      hand.add(_playerActionDeck[i]);
    }
    return hand;
  }

  ActionCard? _drawActionCard() {
    if (_playerActionDeck.isNotEmpty) {
      return _playerActionDeck.removeAt(0);
    }
    return null;
  }

  void _selectHero(HeroModel hero) {
    if (_usedPlayerHeroes.contains(hero)) return;

    final aiHero = _aiDeck[_currentRound - 1];

    // Initialize HP based on Durability stat
    final playerHp =
        (hero.powerStats.durability * 2) + 50; // HP = Durability * 2 + 50
    final aiHp = (aiHero.powerStats.durability * 2) + 50;

    setState(() {
      _selectedPlayerHero = hero;
      _currentAiHero = aiHero;
      _playerMaxHp = playerHp;
      _playerCurrentHp = playerHp;
      _aiMaxHp = aiHp;
      _aiCurrentHp = aiHp;
      _roundInProgress = true;
      _isPlayerTurn = true;
    });

    _addToBattleLog('${hero.name} enters the battle with ${playerHp} HP!');
    _addToBattleLog(
      '${aiHero.name} (Opponent) enters the battle with ${aiHp} HP!',
    );
    _addToBattleLog('=== ROUND $_currentRound BEGINS ===');

    // Start first turn
    _executeTurn();
  }

  void _addToBattleLog(String message) {
    setState(() {
      _battleLog.add(message);
    });

    // Auto-scroll to bottom after UI update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_battleLogScrollController.hasClients) {
        _battleLogScrollController.animateTo(
          _battleLogScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _executeTurn() async {
    if (_selectedPlayerHero == null || _currentAiHero == null) return;

    // Trigger clash animation
    _clashAnimationController.forward().then((_) {
      _clashAnimationController.reverse();
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (_isPlayerTurn) {
      _executePlayerAttack();
    } else {
      _executeAiAttack();
    }

    // Check if battle is over
    if (_playerCurrentHp <= 0 || _aiCurrentHp <= 0) {
      _endRound();
    } else {
      setState(() {
        _isPlayerTurn = !_isPlayerTurn;
      });
    }
  }

  void _executePlayerAttack() {
    final hero = _selectedPlayerHero!;
    final power = (hero.powerStats.strength + hero.powerStats.combat) ~/ 2;
    final damage = power + (hero.powerStats.power ~/ 4);

    setState(() {
      _aiCurrentHp = (_aiCurrentHp - damage).clamp(0, _aiMaxHp);
    });

    _addToBattleLog('${hero.name} attacks for ${damage} damage!');
    _addToBattleLog(
      '${_currentAiHero!.name} has ${_aiCurrentHp}/${_aiMaxHp} HP remaining!',
    );

    _shakeAnimationController.forward().then((_) {
      _shakeAnimationController.reverse();
    });
  }

  void _executeAiAttack() {
    final hero = _currentAiHero!;
    final power = (hero.powerStats.strength + hero.powerStats.combat) ~/ 2;
    final damage = power + (hero.powerStats.power ~/ 4);

    setState(() {
      _playerCurrentHp = (_playerCurrentHp - damage).clamp(0, _playerMaxHp);
    });

    _addToBattleLog('${hero.name} (Opponent) attacks for ${damage} damage!');
    _addToBattleLog(
      '${_selectedPlayerHero!.name} has ${_playerCurrentHp}/${_playerMaxHp} HP remaining!',
    );

    _shakeAnimationController.forward().then((_) {
      _shakeAnimationController.reverse();
    });
  }

  void _endRound() {
    String roundWinner;
    if (_playerCurrentHp <= 0 && _aiCurrentHp <= 0) {
      roundWinner = 'Draw';
    } else if (_playerCurrentHp <= 0) {
      roundWinner = 'Opponent';
      _aiScore++;
      // Update HP tracking and trigger force swap
      if (_playerActiveHero != null) {
        _playerHeroHp[_playerActiveHero!.name] = 0;
        _addToBattleLog('${_playerActiveHero!.name} has been defeated!');
        _checkForForceSwap();
      }
    } else if (_aiCurrentHp <= 0) {
      roundWinner = 'Player';
      _playerScore++;
      // Update HP tracking for AI hero
      if (_aiActiveHero != null) {
        _aiHeroHp[_aiActiveHero!.name] = 0;
        _addToBattleLog('${_aiActiveHero!.name} has been defeated!');
        // Handle AI hero swap (simplified - just pick next available hero)
        _handleAiHeroDefeat();
      }
    } else {
      roundWinner = 'Draw';
    }

    _addToBattleLog('=== ROUND $_currentRound ENDS ===');
    _addToBattleLog('Winner: $roundWinner');

    _roundResults.add(
      RoundResult(
        playerHero: _selectedPlayerHero!,
        aiHero: _currentAiHero!,
        winner: roundWinner,
        roundNumber: _currentRound,
      ),
    );

    _usedPlayerHeroes.add(_selectedPlayerHero!);

    setState(() {
      _roundInProgress = false;
    });
  }

  void _nextTurn() {
    _executeTurn();
  }

  void _nextRound() {
    if (_currentRound >= 5) {
      _endBattle(_playerScore > _aiScore);
    } else {
      setState(() {
        _currentRound++;
        _selectedPlayerHero = null;
        _currentAiHero = null;
        _playerCurrentHp = 0;
        _playerMaxHp = 0;
        _aiCurrentHp = 0;
        _aiMaxHp = 0;
        _isPlayerTurn = true;
        _roundInProgress = false;
      });
    }
  }

  Future<void> _saveBattleResult() async {
    try {
      final deckProvider = context.read<DeckProvider>();
      await DatabaseService().saveBattleResult(
        playerDeck: deckProvider.deck,
        aiDeck: _aiDeck,
        winner: _winner!,
        playerPower: _playerScore,
        aiPower: _aiScore,
      );
    } catch (e) {
      print('Error saving battle result: $e');
    }
  }

  void _goToDeckBuilder() {
    Navigator.pushReplacementNamed(context, '/deck-builder');
  }

  void _goToBattleHistory() {
    Navigator.pushNamed(context, '/history');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Stack(
        children: [
          // Main Battle UI
          SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0f0f1e),
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Top Bar - Score and Energy
                  _buildTopBar(),

                  // Main Battle Arena
                  Expanded(
                    child: Consumer<DeckProvider>(
                      builder: (context, deckProvider, _) {
                        final playerDeck = deckProvider.deck;

                        if (playerDeck.isEmpty) {
                          return _buildEmptyDeckView();
                        }

                        return _isBattling
                            ? _buildTacticalBattleArena()
                            : _buildPreBattleView();
                      },
                    ),
                  ),

                  // Bottom Section - Action Cards or Battle Briefing
                  _buildBottomSection(),
                ],
              ),
            ),
          ),

          // Combat Effect Overlays
          if (_showCriticalHit) _buildCriticalHitOverlay(),

          // Swap Dialog Overlays
          if (_showForceSwapDialog) _buildHeroSwapDialog(isForceSwap: true),

          if (_showManualSwapDialog) _buildHeroSwapDialog(isForceSwap: false),
        ],
      ),
    );
  }

  Widget _buildCriticalHitOverlay() {
    return AnimatedBuilder(
      animation: _criticalHitAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Center(
            child: Transform.scale(
              scale: _criticalHitAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange, width: 3),
                ),
                child: const Text(
                  'CRITICAL HIT!',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyDeckView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'No Deck Available',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please build a deck first',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _goToDeckBuilder,
            icon: const Icon(Icons.style),
            label: const Text('Build Deck'),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleStatus() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(0.3),
                  Colors.red.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                const Text(
                  'BATTLE IN PROGRESS...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
                const SizedBox(height: 10),
                Text(
                  'Calculating power stats...',
                  style: TextStyle(color: Colors.orange.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBattleResult() {
    final isPlayerWin = _winner == 'Player';
    final isDraw = _winner == 'Draw';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDraw
              ? [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.2)]
              : isPlayerWin
              ? [Colors.green.withOpacity(0.3), Colors.blue.withOpacity(0.3)]
              : [Colors.red.withOpacity(0.3), Colors.orange.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDraw
              ? Colors.grey.withOpacity(0.5)
              : isPlayerWin
              ? Colors.green.withOpacity(0.5)
              : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            isDraw ? 'DRAW!' : '$_winner WINS!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDraw
                  ? Colors.grey
                  : isPlayerWin
                  ? Colors.green
                  : Colors.red,
              shadows: [
                Shadow(
                  color: isDraw
                      ? Colors.grey.withOpacity(0.8)
                      : isPlayerWin
                      ? Colors.green.withOpacity(0.8)
                      : Colors.red.withOpacity(0.8),
                  offset: const Offset(2, 2),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    'YOUR POWER',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '$_playerScore',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const Text(
                'VS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Column(
                children: [
                  const Text(
                    'AI POWER',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '$_aiScore',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartBattleButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade600, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _startBattle,
          child: const Center(
            child: Text(
              'START BATTLE',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _goToDeckBuilder,
            icon: const Icon(Icons.style),
            label: const Text('Edit Deck'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _goToBattleHistory,
            icon: const Icon(Icons.history),
            label: const Text('Battle History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreTracker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.3), Colors.red.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              const Text(
                'PLAYER',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '$_playerScore',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Text(
            'VS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            children: [
              const Text(
                'ENEMY STATS',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '$_aiScore',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSelection(List<HeroModel> playerDeck) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'ROUND $_currentRound - Select Your Hero',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: playerDeck.map((hero) {
              final isUsed = _usedPlayerHeroes.contains(hero);
              return GestureDetector(
                onTap: isUsed ? null : () => _selectHero(hero),
                child: Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isUsed
                        ? Colors.grey.withOpacity(0.3)
                        : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isUsed
                          ? Colors.grey.withOpacity(0.5)
                          : Colors.blue.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(13),
                          ),
                          child: Image.network(
                            hero.displayImageUrl.isNotEmpty
                                ? hero.displayImageUrl
                                : 'https://via.placeholder.com/100x80.png?text=?',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[600],
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          hero.name.length > 12
                              ? '${hero.name.substring(0, 12)}...'
                              : hero.name,
                          style: TextStyle(
                            color: isUsed ? Colors.grey : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUsed)
                        const Text(
                          'USED',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRound() {
    if (_selectedPlayerHero == null || _currentAiHero == null)
      return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'ROUND $_currentRound',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Battle Arena with HP Bars
          AnimatedBuilder(
            animation: Listenable.merge([
              _clashAnimation,
              _shakeAnimation,
              _glowAnimation,
            ]),
            builder: (context, child) {
              return Column(
                children: [
                  // Player Card with HP
                  _buildHeroCardWithHp(_selectedPlayerHero!, true),
                  const SizedBox(height: 10),
                  _buildHpBar(_playerCurrentHp, _playerMaxHp, true),

                  const SizedBox(height: 20),

                  // VS Text
                  AnimatedBuilder(
                    animation: _vsSlideAnimation,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _vsSlideAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.yellow.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            _isPlayerTurn ? 'YOUR TURN' : 'OPPONENT TURN',
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // AI Card with HP
                  _buildHeroCardWithHp(_currentAiHero!, false),
                  const SizedBox(height: 10),
                  _buildHpBar(_aiCurrentHp, _aiMaxHp, false),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Battle Log
          _buildBattleLog(),
        ],
      ),
    );
  }

  Widget _buildHeroCardWithHp(HeroModel hero, bool isPlayer) {
    return AnimatedBuilder(
      animation: Listenable.merge([_clashAnimation, _shakeAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: isPlayer
              ? _clashAnimation.value * -0.5
              : _clashAnimation.value * 0.5,
          child: Transform.rotate(
            angle: _shakeAnimation.value * 0.01 * (isPlayer ? 1 : -1),
            child: Container(
              width: 160,
              height: 200,
              decoration: BoxDecoration(
                color: isPlayer
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isPlayer
                      ? Colors.blue.withOpacity(0.5)
                      : Colors.red.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Hero Image
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(13),
                      ),
                      child: Image.network(
                        hero.displayImageUrl.isNotEmpty
                            ? hero.displayImageUrl
                            : 'https://via.placeholder.com/160x120.png?text=?',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[600],
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Hero Info
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            hero.name.length > 15
                                ? '${hero.name.substring(0, 15)}...'
                                : hero.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Power: ${(hero.powerStats.strength + hero.powerStats.combat) ~/ 2}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _buildHpBar(int currentHp, int maxHp, bool isPlayer) {
    final hpPercentage = maxHp > 0 ? currentHp / maxHp : 0.0;
    final hpColor = hpPercentage > 0.5
        ? Colors.green
        : hpPercentage > 0.25
        ? Colors.orange
        : Colors.red;

    return Container(
      width: 160,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // HP Bar Fill
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 160 * hpPercentage,
            height: 20,
            decoration: BoxDecoration(
              color: hpColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // HP Text
          Center(
            child: Text(
              '$currentHp/$maxHp HP',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleLog() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BATTLE LOG',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _battleLog.isEmpty
                      ? 'Waiting for battle to begin...'
                      : _battleLog.join('\n'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextActionButton() {
    // If round is in progress, it's a turn-based button
    if (_roundInProgress) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton.icon(
          onPressed: _nextTurn,
          icon: const Icon(Icons.flash_on),
          label: Text(_isPlayerTurn ? 'Execute Attack' : 'Next Turn'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPlayerTurn ? Colors.green : Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size(200, 50),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            elevation: 8,
            shadowColor: (_isPlayerTurn ? Colors.green : Colors.orange)
                .withOpacity(0.5),
          ),
        ),
      );
    }

    // If round is complete, it's a next round button
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton.icon(
        onPressed: _nextRound,
        icon: Icon(_currentRound >= 5 ? Icons.flag : Icons.arrow_forward),
        label: Text(_currentRound >= 5 ? 'Finish Battle' : 'Next Round'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _currentRound >= 5 ? Colors.purple : Colors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 8,
          shadowColor: (_currentRound >= 5 ? Colors.purple : Colors.orange)
              .withOpacity(0.5),
        ),
      ),
    );
  }

  // NEW TACTICAL BATTLE UI METHODS

  Widget _buildTopBar() {
    return AnimatedBuilder(
      animation: _turnIndicatorAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Player Score
              Column(
                children: [
                  const Text(
                    'PLAYER',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$_playerScore',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Battle Status with Animation
              Transform.scale(
                scale: _isPlayerTurn && _turnIndicatorController.isAnimating
                    ? _turnIndicatorAnimation.value
                    : 1.0,
                child: Text(
                  _battleEnded
                      ? (_winner == 'Player' ? 'VICTORY!' : 'DEFEAT!')
                      : _isPlayerTurn
                      ? 'YOUR TURN'
                      : 'OPPONENT TURN',
                  style: TextStyle(
                    color: _battleEnded
                        ? (_winner == 'Player' ? Colors.green : Colors.red)
                        : (_isPlayerTurn ? Colors.yellow : Colors.orange),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows:
                        _isPlayerTurn && _turnIndicatorController.isAnimating
                        ? [
                            Shadow(
                              color: Colors.yellow.withOpacity(0.8),
                              blurRadius: 10 * _turnIndicatorAnimation.value,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),

              // Enemy Stats & Energy
              Column(
                children: [
                  const Text(
                    'ENEMY',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$_aiScore',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isBattling) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.yellow, size: 16),
                        Text(
                          '$_playerEnergy/$_maxEnergy',
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreBattleView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Title
          Text(
            'TACTICAL BATTLE ARENA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
              shadows: [
                Shadow(
                  color: Colors.red.withOpacity(0.8),
                  offset: const Offset(2, 2),
                  blurRadius: 8,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          if (!_battleComplete) ...[
            _buildBattleStatus(),
            const SizedBox(height: 30),
            _buildStartBattleButton(),
          ] else ...[
            _buildBattleResult(),
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildTacticalBattleArena() {
    return Column(
      children: [
        // Active Heroes Battle Area
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Player Active Hero
                Expanded(child: _buildActiveHeroCard(_playerActiveHero, true)),

                const SizedBox(width: 20),

                // VS Indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.yellow.withOpacity(0.5)),
                  ),
                  child: const Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // AI Active Hero
                Expanded(child: _buildActiveHeroCard(_aiActiveHero, false)),
              ],
            ),
          ),
        ),

        // Battle Briefing Panel
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildBattleBriefing(),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveHeroCard(HeroModel? hero, bool isPlayer) {
    if (hero == null) return const SizedBox();

    final currentHp = isPlayer ? _playerCurrentHp : _aiCurrentHp;
    final maxHp = isPlayer ? _playerMaxHp : _aiMaxHp;
    final hpPercentage = maxHp > 0 ? currentHp / maxHp : 0.0;
    final isLunging = isPlayer ? _isPlayerLunging : _isAiLunging;
    final isShaking = isPlayer ? _isPlayerShaking : _isAiShaking;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _lungeAnimation,
        _damageShakeAnimation,
        _healthBarAnimation,
        _hitFlashAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: isLunging
              ? (isPlayer ? _lungeAnimation.value : -_lungeAnimation.value)
              : isShaking
              ? Offset(
                  _damageShakeAnimation.value * 0.5 * (isPlayer ? 1 : -1),
                  0,
                )
              : Offset.zero,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isPlayer
                        ? [
                            Colors.blue.withOpacity(0.3),
                            Colors.blue.withOpacity(0.1),
                          ]
                        : [
                            Colors.red.withOpacity(0.3),
                            Colors.red.withOpacity(0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPlayer
                        ? Colors.blue.withOpacity(0.5)
                        : Colors.red.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isPlayer ? Colors.blue : Colors.red).withOpacity(
                        0.3,
                      ),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Hero Image - Use Flexible to prevent overflow
                    Flexible(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        child: Image.network(
                          hero.displayImageUrl.isNotEmpty
                              ? hero.displayImageUrl
                              : 'https://via.placeholder.com/200x150.png?text=?',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[600],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Hero Info - Use Column with MainAxisSize.min
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(
                          4,
                        ), // Reduced padding by 4px
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Prevent overflow
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hero.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            // HP Bar with animation
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Stack(
                                children: [
                                  // Background HP bar
                                  FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: hpPercentage,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: hpPercentage > 0.5
                                            ? Colors.green
                                            : hpPercentage > 0.25
                                            ? Colors.orange
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                  // Animated HP bar overlay
                                  if (_healthBarAnimationController.isAnimating)
                                    FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _healthBarAnimation.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              '$currentHp/$maxHp HP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4), // Reduced from Spacer
                            // Stats - Wrap in FittedBox to prevent overflow
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatIcon(
                                    '⚔️',
                                    isPlayer ? _playerAttack : _aiAttack,
                                  ),
                                  _buildStatIcon(
                                    '🛡️',
                                    isPlayer ? _playerDefense : _aiDefense,
                                  ),
                                  _buildStatIcon(
                                    '⚡',
                                    isPlayer ? _playerSpeed : _aiSpeed,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Hit Flash Overlay
              if (_showHitFlash && !isPlayer)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        _hitFlashAnimation.value * 0.6,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatIcon(String icon, int value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBattleBriefing() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 320, // Increased height to reduce gap
      ),
      child: Container(
        width: double.infinity, // Full width
        padding: const EdgeInsets.all(12), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8), // Darker, more consistent color
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Full width for children
          children: [
            const Text(
              'BATTLE BRIEFING',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  scrollbarTheme: ScrollbarThemeData(
                    thumbColor: MaterialStateProperty.all(
                      Colors.white.withOpacity(0.5),
                    ),
                    thickness: MaterialStateProperty.all(6),
                    crossAxisMargin: 0, // Pin to edge
                    mainAxisMargin: 0, // Pin to edge
                  ),
                ),
                child: Scrollbar(
                  controller: _battleLogScrollController,
                  thumbVisibility: true, // Always show scrollbar
                  child: SingleChildScrollView(
                    controller: _battleLogScrollController,
                    child: Text(
                      _battleLog.isEmpty
                          ? 'Awaiting battle commencement...'
                          : _battleLog.join('\n'),
                      textAlign: TextAlign.left,
                      softWrap: true, // Enable text wrapping
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        height:
                            1.6, // Increased line height for better readability
                      ),
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

  Widget _buildBottomSection() {
    if (!_isBattling) return const SizedBox();

    return SafeArea(
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
        ),
        child: _showActionMenu ? _buildActionMenu() : _buildActionHand(),
      ),
    );
  }

  Widget _buildActionHand() {
    return Column(
      children: [
        // Draw Card Button
        if (_playerHand.length < 5 && _isPlayerTurn)
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _drawCardFromDeck,
              icon: const Icon(Icons.add_circle, size: 16),
              label: const Text('Draw Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 30),
              ),
            ),
          ),

        const SizedBox(height: 8),

        // Action Cards Hand
        Expanded(
          child: Row(
            children: _playerHand
                .map(
                  (card) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildActionCard(card),
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        // End Turn Button
        if (_isPlayerTurn)
          ElevatedButton(
            onPressed: _endPlayerTurn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('END TURN'),
          ),
      ],
    );
  }

  Widget _buildActionCard(ActionCard card) {
    final canAfford = _playerEnergy >= card.energyCost;

    return GestureDetector(
      onTap: canAfford && _isPlayerTurn ? () => _selectActionCard(card) : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: card.type == 'attack'
                ? [Colors.red.withOpacity(0.6), Colors.red.withOpacity(0.3)]
                : card.type == 'skill'
                ? [
                    Colors.purple.withOpacity(0.6),
                    Colors.purple.withOpacity(0.3),
                  ]
                : card.type == 'defend'
                ? [Colors.blue.withOpacity(0.6), Colors.blue.withOpacity(0.3)]
                : [
                    Colors.green.withOpacity(0.6),
                    Colors.green.withOpacity(0.3),
                  ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canAfford && _isPlayerTurn
                ? Colors.yellow
                : Colors.white.withOpacity(0.3),
            width: canAfford && _isPlayerTurn ? 2 : 1,
          ),
          boxShadow: canAfford && _isPlayerTurn
              ? [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Energy Cost
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: Colors.yellow, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      '${card.energyCost}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Card Name
              Text(
                card.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Damage/Effect
              if (card.damage > 0)
                Text(
                  'DMG: ${card.damage}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              // Description
              Text(
                card.description,
                style: const TextStyle(color: Colors.white70, fontSize: 8),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu() {
    return Column(
      children: [
        const Text(
          'Choose Action:',
          style: TextStyle(
            color: Colors.yellow,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _executeAction('basic_attack'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Basic Attack'),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: ElevatedButton(
                onPressed: () => _executeAction('defend'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Defend'),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: ElevatedButton(
                onPressed: _playerEnergy >= 1
                    ? () => _openManualSwapDialog()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _playerEnergy >= 1
                      ? Colors.green
                      : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Swap Hero'),
                    if (_playerEnergy >= 1)
                      const Text('Cost: 1', style: TextStyle(fontSize: 10)),
                    if (_playerEnergy < 1)
                      const Text('No Energy', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // SWAP CHECK METHODS
  void _checkForForceSwap() {
    // Check if player has any heroes with HP > 0
    final availableHeroes = _playerActiveHeroes
        .where(
          (hero) =>
              (_playerHeroHp[hero.name] ?? 0) > 0 &&
              hero.name != _playerActiveHero?.name,
        )
        .toList();

    if (availableHeroes.isNotEmpty) {
      // Show force swap dialog
      _openForceSwapDialog();
    } else {
      // No heroes left, end battle
      _endBattle(false);
    }
  }

  void _handleAiHeroDefeat() {
    // Find next available AI hero
    final availableHeroes = _aiDeck
        .where(
          (hero) =>
              (_aiHeroHp[hero.name] ?? 0) > 0 &&
              hero.name != _aiActiveHero?.name,
        )
        .toList();

    if (availableHeroes.isNotEmpty) {
      // Swap to next AI hero
      final oldHeroName = _aiActiveHero?.name ?? 'Unknown';
      _aiActiveHero = availableHeroes.first;
      _aiCurrentHp =
          _aiHeroHp[_aiActiveHero!.name] ??
          ((_aiActiveHero!.powerStats.durability * 2) + 50);
      _aiMaxHp = (_aiActiveHero!.powerStats.durability * 2) + 50;
      _aiAttack = _aiActiveHero!.powerStats.strength;
      _aiDefense = _aiActiveHero!.powerStats.durability ~/ 2;
      _aiSpeed = _aiActiveHero!.powerStats.speed;

      _addToBattleLog(
        '$oldHeroName retreats! ${_aiActiveHero!.name} enters the fray!',
      );
    } else {
      // No AI heroes left, end battle
      _endBattle(true);
    }
  }

  // COMBAT ANIMATION METHODS
  Future<void> _playLungeAttack(bool isPlayer) async {
    setState(() {
      if (isPlayer) {
        _isPlayerLunging = true;
      } else {
        _isAiLunging = true;
      }
    });

    // Play lunge animation
    if (isPlayer) {
      await _lungeAnimationController.forward();
      await _lungeAnimationController.reverse();
    } else {
      await _lungeAnimationController.forward();
      await _lungeAnimationController.reverse();
    }

    setState(() {
      if (isPlayer) {
        _isPlayerLunging = false;
      } else {
        _isAiLunging = false;
      }
    });
  }

  Future<void> _playDamageShake(bool isPlayer) async {
    setState(() {
      if (isPlayer) {
        _isPlayerShaking = true;
      } else {
        _isAiShaking = true;
      }
    });

    // Play shake animation
    await _damageShakeController.forward();
    await _damageShakeController.reverse();

    setState(() {
      if (isPlayer) {
        _isPlayerShaking = false;
      } else {
        _isAiShaking = false;
      }
    });
  }

  Future<void> _playHitFlash(bool isPlayer) async {
    setState(() {
      _showHitFlash = true;
    });

    await _hitFlashController.forward();
    await _hitFlashController.reverse();

    setState(() {
      _showHitFlash = false;
    });
  }

  Future<void> _playCriticalHit() async {
    setState(() {
      _showCriticalHit = true;
    });

    await _criticalHitController.forward();
    await _criticalHitController.reverse();

    setState(() {
      _showCriticalHit = false;
    });
  }

  Future<void> _animateHealthBar(bool isPlayer, int newHp) async {
    if (isPlayer) {
      _targetPlayerHp = newHp.toDouble();
    } else {
      _targetAiHp = newHp.toDouble();
    }

    await _healthBarAnimationController.forward();

    setState(() {
      if (isPlayer) {
        _playerCurrentHp = newHp;
      } else {
        _aiCurrentHp = newHp;
      }
    });

    _healthBarAnimationController.reset();
  }

  Future<void> _playTurnIndicator() async {
    await _turnIndicatorController.forward();
    await _turnIndicatorController.reverse();
  }

  Future<void> _executeAttackSequence(
    bool isPlayer,
    int damage, {
    bool isCritical = false,
  }) async {
    // Step 1: Lunge attack
    await _playLungeAttack(isPlayer);

    // Step 2: Hit flash on target
    await _playHitFlash(!isPlayer);

    // Step 3: Damage shake on target
    await _playDamageShake(!isPlayer);

    // Step 4: Critical hit effect if applicable
    if (isCritical) {
      await _playCriticalHit();
    }

    // Step 5: Animate health bar
    final targetHp = isPlayer
        ? _aiCurrentHp - damage
        : _playerCurrentHp - damage;
    await _animateHealthBar(
      !isPlayer,
      targetHp.clamp(0, isPlayer ? _aiMaxHp : _playerMaxHp),
    );

    // Step 6: Update battle log after animations complete
    if (isPlayer) {
      _addToBattleLog('${_playerActiveHero?.name} deals $damage damage!');
      if (isCritical) {
        _addToBattleLog('CRITICAL HIT!');
      }
    } else {
      _addToBattleLog('${_aiActiveHero?.name} deals $damage damage!');
    }
  }

  // SWAP METHODS
  void _openManualSwapDialog() {
    setState(() {
      _showManualSwapDialog = true;
    });
  }

  void _closeManualSwapDialog() {
    setState(() {
      _showManualSwapDialog = false;
    });
  }

  void _openForceSwapDialog() {
    setState(() {
      _showForceSwapDialog = true;
    });
  }

  void _closeForceSwapDialog() {
    setState(() {
      _showForceSwapDialog = false;
    });
  }

  void _swapHero(HeroModel newHero) {
    if (_isSwapping) return;

    setState(() {
      _isSwapping = true;
    });

    final oldHeroName = _playerActiveHero?.name ?? 'Unknown';

    // Update HP tracking for the old hero
    if (_playerActiveHero != null) {
      _playerHeroHp[_playerActiveHero!.name] = _playerCurrentHp;
    }

    // Switch to new hero
    _playerActiveHero = newHero;
    _playerCurrentHp =
        _playerHeroHp[newHero.name] ??
        ((newHero.powerStats.durability * 2) + 50);
    _playerMaxHp = (newHero.powerStats.durability * 2) + 50;
    _playerAttack = newHero.powerStats.strength;
    _playerDefense = newHero.powerStats.durability ~/ 2;
    _playerSpeed = newHero.powerStats.speed;

    // Generate new action deck for the new hero
    _playerActionDeck = _generateActionDeck(newHero);
    _playerHand = _drawInitialHand();

    // Update battle log
    _addToBattleLog('$oldHeroName retreats! ${newHero.name} enters the fray!');

    // Handle manual swap penalty
    if (_showManualSwapDialog) {
      _playerEnergy = (_playerEnergy - 1).clamp(0, _maxEnergy);
      _addToBattleLog('Swap costs 1 energy. Remaining: $_playerEnergy');
      _closeManualSwapDialog();

      // End turn after manual swap
      _endPlayerTurn();
    } else {
      // Force swap - continue the battle
      _closeForceSwapDialog();
    }

    setState(() {
      _isSwapping = false;
    });
  }

  Widget _buildHeroSwapDialog({required bool isForceSwap}) {
    final deckProvider = context.read<DeckProvider>();
    final playerDeck = deckProvider.deck;

    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isForceSwap ? 'FORCE SWAP - Hero Defeated!' : 'Switch Hero',
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              isForceSwap
                  ? 'Your hero was defeated! Choose a new hero to continue fighting.'
                  : 'Choose a hero to swap in (Cost: 1 Energy)',
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Hero selection grid
            SizedBox(
              height: 120,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: playerDeck.length,
                itemBuilder: (context, index) {
                  final hero = playerDeck[index];
                  final heroHp = _playerHeroHp[hero.name] ?? 0;
                  final isActive = _playerActiveHero?.name == hero.name;
                  final isDefeated = heroHp <= 0;

                  return GestureDetector(
                    onTap: isDefeated || isActive
                        ? null
                        : () => _swapHero(hero),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.yellow.withOpacity(0.3)
                            : isDefeated
                            ? Colors.grey.withOpacity(0.3)
                            : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? Colors.yellow
                              : isDefeated
                              ? Colors.grey
                              : Colors.blue.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isActive)
                            const Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 16,
                            ),
                          if (isDefeated)
                            const Icon(
                              Icons.block,
                              color: Colors.grey,
                              size: 16,
                            ),

                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: hero.displayImageUrl.isNotEmpty
                                  ? Image.network(
                                      hero.displayImageUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                            ),
                          ),

                          Text(
                            hero.name.length > 8
                                ? '${hero.name.substring(0, 8)}...'
                                : hero.name,
                            style: TextStyle(
                              color: isDefeated ? Colors.grey : Colors.white,
                              fontSize: 8,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          Text(
                            '$heroHp HP',
                            style: TextStyle(
                              color: isDefeated ? Colors.grey : Colors.green,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            if (!isForceSwap)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _closeManualSwapDialog,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // NEW BATTLE METHODS

  void _drawCardFromDeck() {
    if (!_isPlayerTurn || _playerHand.length >= 5) return;

    final newCard = _drawActionCard();
    if (newCard != null) {
      setState(() {
        _playerHand.add(newCard);
      });
      _addToBattleLog('Drew ${newCard.name} from deck!');
    }
  }

  void _selectActionCard(ActionCard card) {
    if (_playerEnergy < card.energyCost) return;

    setState(() {
      _selectedActionCard = card;
      _showActionMenu = false;
    });

    _executeActionCard(card);
  }

  void _executeActionCard(ActionCard card) {
    if (_playerEnergy < card.energyCost) return;

    setState(() {
      _playerEnergy -= card.energyCost;
      _playerHand.remove(card);
    });

    _addToBattleLog('${_playerActiveHero?.name} uses ${card.name}!');

    if (card.type == 'attack' || card.type == 'skill') {
      final damage = card.damage;
      setState(() {
        _aiCurrentHp = (_aiCurrentHp - damage).clamp(0, _aiMaxHp);
      });
      _addToBattleLog('Dealt $damage damage!');
      _addToBattleLog(
        '${_aiActiveHero?.name} has $_aiCurrentHp/$_aiMaxHp HP remaining!',
      );

      // Check if AI hero is defeated
      if (_aiCurrentHp <= 0) {
        _handleHeroDefeated(false);
      }
    } else if (card.type == 'defend') {
      _addToBattleLog('${_playerActiveHero?.name} takes a defensive stance!');
    } else if (card.type == 'heal') {
      final healAmount = card.damage;
      setState(() {
        _playerCurrentHp = (_playerCurrentHp + healAmount).clamp(
          0,
          _playerMaxHp,
        );
      });
      _addToBattleLog('Restored $healAmount HP!');
      _addToBattleLog(
        '${_playerActiveHero?.name} has $_playerCurrentHp/$_playerMaxHp HP!',
      );
    }

    // End turn after action
    _endPlayerTurn();
  }

  void _executeAction(String action) async {
    switch (action) {
      case 'basic_attack':
        final damage = (_playerAttack * 0.7).round();
        final isCritical =
            (DateTime.now().millisecond % 5) ==
            0; // 20% chance for critical hit

        _addToBattleLog('${_playerActiveHero?.name} performs a basic attack!');

        // Play the full attack sequence
        await _executeAttackSequence(true, damage, isCritical: isCritical);

        _addToBattleLog(
          '${_aiActiveHero?.name} has $_aiCurrentHp/$_aiMaxHp HP remaining!',
        );

        if (_aiCurrentHp <= 0) {
          _handleHeroDefeated(false);
        } else {
          _endPlayerTurn();
        }
        break;

      case 'defend':
        _addToBattleLog('${_playerActiveHero?.name} defends!');
        _endPlayerTurn();
        break;

      case 'swap_hero':
        _openManualSwapDialog();
        break;
    }
  }

  void _endPlayerTurn() {
    setState(() {
      _isPlayerTurn = false;
      _showActionMenu = false;
    });

    // AI turn
    Future.delayed(const Duration(milliseconds: 1000), () {
      _executeAITurn();
    });
  }

  void _executeAITurn() async {
    if (_battleEnded) return;

    _addToBattleLog('${_aiActiveHero?.name}\'s turn!');

    // Simple AI logic
    final damage = (_aiAttack * 0.6).round();
    final isCritical =
        (DateTime.now().millisecond % 8) == 0; // 12.5% chance for critical hit

    _addToBattleLog('${_aiActiveHero?.name} attacks!');

    // Play the full attack sequence
    await _executeAttackSequence(false, damage, isCritical: isCritical);

    _addToBattleLog(
      '${_playerActiveHero?.name} has $_playerCurrentHp/$_playerMaxHp HP remaining!',
    );

    if (_playerCurrentHp <= 0) {
      _handleHeroDefeated(true);
    } else {
      _startNewTurn();
    }
  }

  void _startNewTurn() async {
    setState(() {
      _isPlayerTurn = true;
      _playerEnergy = _maxEnergy;
      _showActionMenu = true;
    });

    // Play turn indicator animation
    await _playTurnIndicator();

    _addToBattleLog('=== NEW TURN ===');
    _addToBattleLog('Energy restored to $_playerEnergy!');

    // Draw a card if hand is not full
    if (_playerHand.length < 5) {
      _drawCardFromDeck();
    }
  }

  void _handleHeroDefeated(bool isPlayerHero) {
    setState(() {
      _heroDefeated = true;
    });

    if (isPlayerHero) {
      _addToBattleLog('${_playerActiveHero?.name} has been defeated!');
      _playerActiveHeroes.remove(_playerActiveHero);

      if (_playerActiveHeroes.isEmpty) {
        _endBattle(false);
      } else {
        _forceHeroSwap();
      }
    } else {
      _addToBattleLog('${_aiActiveHero?.name} has been defeated!');
      _aiDeck.remove(_aiActiveHero);

      if (_aiDeck.isEmpty) {
        _endBattle(true);
      } else {
        setState(() {
          _aiActiveHero = _aiDeck.first;
        });
        _initializeHeroStats();
        _addToBattleLog('${_aiActiveHero?.name} enters the battle!');
      }
    }
  }

  void _forceHeroSwap() {
    if (_playerActiveHeroes.isNotEmpty) {
      setState(() {
        _playerActiveHero = _playerActiveHeroes.first;
      });
      _initializeHeroStats();
      _addToBattleLog('${_playerActiveHero?.name} is forced into battle!');
      _startNewTurn();
    } else {
      _endBattle(false);
    }
  }

  void _endBattle(bool playerWon) {
    setState(() {
      _battleEnded = true;
      _isBattling = false;
      _battleComplete = true;
      _winner = playerWon ? 'Player' : 'Opponent';

      if (playerWon) {
        _playerScore++;
      } else {
        _aiScore++;
      }
    });

    _addToBattleLog('=== BATTLE ENDED ===');
    _addToBattleLog('${_winner} is victorious!');

    // Save to battle history
    _saveBattleResult();
    _saveToBattleHistory(playerWon);
  }

  void _saveToBattleHistory(bool playerWon) async {
    try {
      final deckProvider = context.read<DeckProvider>();
      final battleHistoryProvider = context.read<BattleHistoryProvider>();

      // Get player heroes names
      final playerHeroNames = deckProvider.deck
          .map((hero) => hero.name)
          .toList();

      // Get opponent heroes names
      final opponentHeroNames = _aiDeck.map((hero) => hero.name).toList();

      // Create final score string
      final finalScore = '$_playerScore-$_aiScore';

      // Create battle summary from the log
      final battleSummary = _battleLog.join('\n');

      // Save to battle history
      await battleHistoryProvider.saveBattle(
        playerTeamName: 'Player Team',
        opponentName: 'Opponent Team',
        finalScore: finalScore,
        winner: playerWon ? 'Player' : 'Opponent',
        playerHeroes: playerHeroNames,
        opponentHeroes: opponentHeroNames,
        battleSummary: battleSummary,
      );

      _addToBattleLog('Battle saved to history!');
    } catch (e) {
      _addToBattleLog('Error saving battle: $e');
    }
  }
}
