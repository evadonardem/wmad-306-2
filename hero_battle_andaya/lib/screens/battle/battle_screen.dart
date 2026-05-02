import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/battle_provider.dart';
import '../../services/superhero_api_service.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({Key? key}) : super(key: key);

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  bool _isBattling = false;
  List<String> _battleLog = [];
  HeroModel? _selectedPlayerHero;
  HeroModel? _selectedOpponentHero;
  bool _isComputerOpponent = false;
  final _apiService = SuperheroApiService();

  Future<void> _startBattle() async {
    if (_selectedPlayerHero == null || _selectedOpponentHero == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both heroes for battle!')),
      );
      return;
    }

    // Start battle using BattleProvider
    context.read<BattleProvider>().startBattle(
      _selectedPlayerHero!, 
      _selectedOpponentHero!,
      isComputerOpponent: _isComputerOpponent,
    );
    
    setState(() {
      _isBattling = true;
      _battleLog = [];
    });
  }

  void _showBattleResult(BattleState battleState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(battleState.isPlayerDefeated ? 'Defeat!' : 'Victory!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rounds: ${battleState.turn}'),
            const SizedBox(height: 16),
            const Text('Battle saved to records!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<BattleProvider>().endBattle();
              setState(() {
                _isBattling = false;
                _battleLog = [];
              });
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/history');
            },
            child: const Text('View Records'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battle'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/history'),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Hero selection section
            Consumer<DeckProvider>(
              builder: (context, deckProvider, _) => Column(
                children: [
                  const Text(
                    'Select Your Hero',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (deckProvider.deck.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No heroes in deck! Add heroes from home screen.'),
                      ),
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: deckProvider.deck.length,
                        itemBuilder: (context, index) {
                          final hero = deckProvider.deck[index];
                          final isSelected = _selectedPlayerHero?.id == hero.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPlayerHero = hero;
                              });
                            },
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey,
                                  width: isSelected ? 3 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.blue,
                                    child: Text(
                                      hero.name.isNotEmpty ? hero.name[0] : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hero.name,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Opponent selection
            Column(
              children: [
                const Text(
                  'Select Opponent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<HeroModel>>(
                  future: _apiService.fetchRandomHeroes(count: 5),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Error loading opponents: ${snapshot.error}'),
                        ),
                      );
                    }
                    
                    final opponents = snapshot.data ?? [];
                    return SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: opponents.length,
                        itemBuilder: (context, index) {
                          final hero = opponents[index];
                          final isSelected = _selectedOpponentHero?.id == hero.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedOpponentHero = hero;
                              });
                            },
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? Colors.red : Colors.grey,
                                  width: isSelected ? 3 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.red,
                                    child: Text(
                                      hero.name.isNotEmpty ? hero.name[0] : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hero.name,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Selected heroes display
            if (_selectedPlayerHero != null && _selectedOpponentHero != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _HeroCard(hero: _selectedPlayerHero!, isPlayer: true),
                  const Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  _HeroCard(hero: _selectedOpponentHero!, isPlayer: false),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Battle mode toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text('Battle Mode:'),
                    const Spacer(),
                    const Text('Manual'),
                    Switch(
                      value: _isComputerOpponent,
                      onChanged: (value) {
                        setState(() {
                          _isComputerOpponent = value;
                        });
                      },
                    ),
                    const Text('Computer'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Battle button - always visible
            ElevatedButton(
              onPressed: _isBattling ? null : _startBattle,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: _isBattling
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Battling...'),
                      ],
                    )
                  : Text(_isComputerOpponent ? 'Begin Computer Combat' : 'Begin Combat'),
            ),
            
            const SizedBox(height: 16),
            
            // Battle controls and log - takes remaining space
            Expanded(
              child: Consumer<BattleProvider>(
                builder: (context, battleProvider, _) {
                  final battle = battleProvider.currentBattle;
                  
                  if (battle != null) {
                    // Show battle result dialog for computer battles
                    if (battle.isBattleOver && battleProvider.isComputerOpponent) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _showBattleResult(battle);
                      });
                    }
                    
                    return Column(
                      children: [
                        // Battle status
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Player HP: ${battle.playerHp}/${battle.playerMaxHp}'),
                                    Text('Opponent HP: ${battle.opponentHp}/${battle.opponentMaxHp}'),
                                  ],
                                ),
                                Text(
                                  battleProvider.battleStatus,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Battle actions
                        if (!battle.isBattleOver && !battleProvider.isComputerOpponent)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (battle.isPlayerTurn)
                                ElevatedButton(
                                  onPressed: () {
                                    battleProvider.playerAttack();
                                    // Auto opponent attack after player
                                    Future.delayed(const Duration(milliseconds: 500), () {
                                      if (battleProvider.currentBattle != null && 
                                          !battleProvider.currentBattle!.isPlayerTurn &&
                                          !battleProvider.currentBattle!.isBattleOver) {
                                        battleProvider.opponentAttack();
                                      }
                                    });
                                  },
                                  child: const Text('Strike'),
                                )
                              else
                                const ElevatedButton(
                                  onPressed: null,
                                  child: const Text('Enemy Turn...'),
                                ),
                              
                              ElevatedButton(
                                onPressed: () {
                                  battleProvider.endBattle();
                                  setState(() {
                                    _isBattling = false;
                                    _battleLog = [];
                                  });
                                },
                                child: const Text('Stop Combat'),
                              ),
                            ],
                          ),
                        
                        // Computer battle status
                        if (!battle.isBattleOver && battleProvider.isComputerOpponent)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 16),
                                  Text('Computer vs Computer battle in progress...'),
                                ],
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Battle log
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Battle Log',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: battle.battleLog.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text(battle.battleLog[index]),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Show result dialog when battle ends
                        if (battle.isBattleOver)
                          FutureBuilder(
                            future: Future.delayed(const Duration(milliseconds: 100)),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _showBattleResult(battle);
                                });
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                      ],
                    );
                  } else {
                    // Original battle log when no battle is active
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Battle Log',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: _battleLog.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Start a battle to see the log',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _battleLog.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text(_battleLog[index]),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final HeroModel hero;
  final bool isPlayer;

  const _HeroCard({
    Key? key,
    required this.hero,
    required this.isPlayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: isPlayer ? Colors.blue : Colors.red,
              child: Text(
                hero.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hero.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Power: ${hero.powerStats.power}'),
            Text('Speed: ${hero.powerStats.speed}'),
            Text('Defense: ${hero.defense}'),
          ],
        ),
      ),
    );
  }
}
