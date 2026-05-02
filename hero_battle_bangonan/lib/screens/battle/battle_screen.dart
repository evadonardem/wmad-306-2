import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../models/battle_record.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/player_provider.dart';
import '../../services/superhero_api_service.dart';
import '../../engine/battle_engine.dart';
import '../../widgets/hp_bar.dart';
import '../../router/app_router.dart';

const String kApiToken = 'd4b3dc4ee502cb88da9ad9467d4c2208';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late HeroModel _playerHero;
  late HeroModel _aiHero;
  bool _battleStarted = false;
  bool _heroSelected = false;
  final _api = SuperheroApiService(apiToken: kApiToken);
  late ScrollController _logScrollController;

  @override
  void initState() {
    super.initState();
    _logScrollController = ScrollController();
    // Delay dialog showing until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showHeroSelectionDialog();
    });
  }

  void _showHeroSelectionDialog() {
    final deck = context.read<DeckProvider>();
    if (deck.deck.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your deck is empty. Add heroes first.')),
      );
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Select Player Hero'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: deck.deck.length,
            itemBuilder: (context, i) {
              final hero = deck.deck[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(hero.name),
                  subtitle: Text('HP: ${hero.maxHp} | ATK: ${hero.attack}'),
                  onTap: () {
                    _playerHero = hero;
                    Navigator.pop(context);
                    _showOpponentSelectionDialog();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showOpponentSelectionDialog() {
    final deck = context.read<DeckProvider>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Select Opponent Hero'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: deck.deck.length,
            itemBuilder: (context, i) {
              final hero = deck.deck[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(hero.name),
                  subtitle: Text('HP: ${hero.maxHp} | ATK: ${hero.attack}'),
                  onTap: () {
                    _aiHero = hero;
                    Navigator.pop(context);
                    _startBattle();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _startBattle() {
    if (mounted) {
      setState(() {
        _battleStarted = true;
        _heroSelected = true;
      });
      context.read<BattleProvider>().startBattle(_playerHero, _aiHero);
    }
  }

  void _executeTurn() {
    final battle = context.read<BattleProvider>();
    battle.executeTurn(_playerHero, _aiHero);
    _autoScroll();
  }

  void _autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _endBattle() {
    final battle = context.read<BattleProvider>();
    final battleState = battle.battleState!;
    final playerWon = BattleEngine.playerWon(battleState);

    if (playerWon) {
      context.read<PlayerProvider>().incrementWins();
    }

    final record = BattleRecord(
      playerHero: _playerHero.name,
      aiHero: _aiHero.name,
      playerWon: playerWon,
      roundsPlayed: battleState.round,
      playedAt: DateTime.now().toIso8601String(),
    );

    battle.saveBattleRecord(record);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(playerWon ? 'Victory!' : 'Defeat!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_playerHero.name} vs ${_aiHero.name}'),
            const SizedBox(height: 8),
            Text('Rounds: ${battleState.round}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Home'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              battle.resetBattle();
              setState(() => _battleStarted = false);
              _showHeroSelectionDialog();
            },
            child: const Text('New Battle'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_battleStarted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Battle')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Battle')),
      body: Consumer<BattleProvider>(
        builder: (context, battle, _) {
          final battleState = battle.battleState;
          if (battleState == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final isBattleOver = BattleEngine.isBattleOver(battleState);

          return Column(
            children: [
              // Hero Names & Stats Header
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Player Hero
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _playerHero.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '⚔️ ATK: ${_playerHero.attack}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Text('vs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          'Round ${battleState.round}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange),
                        ),
                      ],
                    ),
                    // AI Hero
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _aiHero.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '⚔️ ATK: ${_aiHero.attack}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // HP Bars
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: HPBar(
                        currentHP: battleState.playerHP,
                        maxHP: _playerHero.maxHp,
                        label: 'Your Hero',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: HPBar(
                        currentHP: battleState.aiHP,
                        maxHP: _aiHero.maxHp,
                        label: 'AI Hero',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Battle Log
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    controller: _logScrollController,
                    itemCount: battleState.log.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        battleState.log[i],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            onPressed: isBattleOver ? null : _executeTurn,
                            icon: const Icon(Icons.bolt),
                            label: const Text('Execute Turn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: isBattleOver
                                ? _endBattle
                                : () {
                                    Navigator.pushReplacementNamed(context, RouteNames.home);
                                  },
                            icon: Icon(isBattleOver ? Icons.check : Icons.exit_to_app),
                            label: Text(
                              isBattleOver ? 'Finish' : 'Flee',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isBattleOver)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Tap "Execute Turn" to let the AI make a move',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
