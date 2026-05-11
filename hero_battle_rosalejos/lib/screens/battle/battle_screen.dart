import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/player_provider.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hp_bar.dart';
import '../../widgets/stat_row.dart';
import '../../models/hero_model.dart';
import '../../widgets/hero_card.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('BATTLE ARENA'),
          toolbarHeight: 35,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white, size: 18),
              onPressed: () => _showBattleMechanics(context),
            ),
          ],
        ),
        body: Consumer3<BattleProvider, DeckProvider, PlayerProvider>(
          builder: (context, battle, deck, player, _) {
            if (battle.playerHero == null && !battle.isGameOver) {
              return _buildSelectionPhase(context, deck, battle);
            }
            if (battle.isIntroActive) {
              return const BattleIntroCountdown();
            }
            return _buildBattleUI(context, battle, player);
          },
        ),
      ),
    );
  }

  void _showBattleMechanics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.indigo.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('BATTLE MECHANICS', 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• HP = (Durability * 5) + Strength', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 8),
              Text('• Damage = (Stat * 1.5) - Opponent Defense', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 8),
              Text('• Moves:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('  - Brutal Strike: STR vs DUR', style: TextStyle(color: Colors.white70)),
              Text('  - Energy Manifest: PWR vs INT', style: TextStyle(color: Colors.white70)),
              Text('  - Precision Assault: CBT vs SPD', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 8),
              Text('• Type Advantage (1.2x):', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('  Good > Bad > Neutral > Good', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('UNDERSTOOD', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionPhase(BuildContext context, DeckProvider deck, BattleProvider battle) {
    if (deck.deck.isEmpty) {
      return const Center(child: Text('Your deck is empty!'));
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text('SELECT YOUR STARTING HERO',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: deck.deck.length,
            itemBuilder: (context, i) {
              final hero = deck.deck[i];
              return HeroCard(
                hero: hero,
                onTap: () async {
                  showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
                  final api = context.read<SuperheroApiService>();
                  try {
                    final all = await api.fetchAllHeroes();
                    if (context.mounted) {
                      Navigator.pop(context);
                      battle.startBattle(deck.deck, all, i);
                      battle.setIntroActive(true);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBattleUI(BuildContext context, BattleProvider battle, PlayerProvider player) {
    if (battle.isAwaitingSwitch && !battle.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSwitchHeroDialog(context, battle);
      });
    }

    return Stack(
      children: [
        Column(
          children: [
            // Enemy Info Row
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(battle.aiName?.toUpperCase() ?? 'OPPONENT', 
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(battle.aiDeck.length, (i) {
                        final hero = battle.aiDeck[i];
                        final isFainted = battle.faintedAiIndices.contains(i);
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/hero', arguments: hero),
                          child: Container(
                            margin: const EdgeInsets.only(right: 4),
                            width: 30,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: i == battle.currentAiIndex ? Colors.redAccent : Colors.white10,
                                width: i == battle.currentAiIndex ? 1.5 : 0.5,
                              ),
                            ),
                            child: Opacity(
                              opacity: isFainted ? 0.2 : 1.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: CachedNetworkImage(imageUrl: hero.imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Pitted Area
            Expanded(
              flex: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (battle.playerHero != null)
                    Expanded(child: _buildHeroCardCombatant(battle.playerHero!, battle.playerHp, isPlayer: true)),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text('VS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white10)),
                  ),

                  if (battle.aiHero != null)
                    Expanded(child: _buildHeroCardCombatant(battle.aiHero!, battle.aiHp, isPlayer: false)),
                ],
              ),
            ),

            // Battle Terminal
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  reverse: true,
                  itemCount: battle.logs.length,
                  itemBuilder: (context, i) {
                    final log = battle.logs[battle.logs.length - 1 - i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: _buildTerminalLog(log),
                    );
                  },
                ),
              ),
            ),

            // User Info Row
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(player.playerName.toUpperCase(), 
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: List.generate(battle.playerDeck.length, (i) {
                        final hero = battle.playerDeck[i];
                        final isFainted = battle.faintedPlayerIndices.contains(i);
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/hero', arguments: hero),
                          child: Container(
                            margin: const EdgeInsets.only(left: 4),
                            width: 30,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: i == battle.currentPlayerIndex ? Colors.greenAccent : Colors.white10,
                                width: i == battle.currentPlayerIndex ? 1.5 : 0.5,
                              ),
                            ),
                            child: Opacity(
                              opacity: isFainted ? 0.2 : 1.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: CachedNetworkImage(imageUrl: hero.imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons Grid
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 4),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 3.2,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildActionButton(context, battle, 'Brutal Strike', 'STR vs DUR', Colors.orange.shade200.withAlpha(200)),
                    _buildActionButton(context, battle, 'Energy Manifest', 'PWR vs INT', Colors.blue.shade200.withAlpha(200)),
                    _buildActionButton(context, battle, 'Precision Assault', 'CBT vs SPD', Colors.red.shade200.withAlpha(200)),
                    _buildActionButton(context, battle, 'Retreat', 'SWAP HERO', Colors.grey.shade300.withAlpha(200), isRetreat: true),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (battle.isGameOver)
          Positioned.fill(
            child: BattleResultOverlay(
              winner: battle.winner ?? 'UNKNOWN',
              isPlayerWinner: battle.winner != battle.aiName,
              onClose: () {
                battle.reset();
                Navigator.pop(context);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTerminalLog(BattleLog log) {
    if (log.actorName == null) {
      return Text(log.text, style: const TextStyle(fontSize: 12, color: Colors.white60, fontFamily: 'monospace'));
    }

    Color actorColor = log.isPlayerActor == true ? Colors.blueAccent : Colors.redAccent;
    Color actionColor = Colors.white70;

    if (log.actionName != null) {
      if (log.actionName!.contains('Brutal')) {
        actionColor = Colors.orange.shade200;
      } else if (log.actionName!.contains('Energy')) {
        actionColor = Colors.blue.shade200;
      } else if (log.actionName!.contains('Precision')) {
        actionColor = Colors.red.shade200;
      } else if (log.actionName!.contains('Retreat')) {
        actionColor = Colors.grey.shade400;
      }
    }

    List<String> parts = log.text.split(log.actorName!);
    String restOfText = parts.length > 1 ? parts[1] : '';
    
    List<TextSpan> spans = [];
    spans.add(TextSpan(text: log.actorName, style: TextStyle(color: actorColor, fontWeight: FontWeight.bold)));
    
    if (log.actionName != null && restOfText.contains(log.actionName!)) {
      List<String> actionParts = restOfText.split(log.actionName!);
      spans.add(TextSpan(text: actionParts[0], style: const TextStyle(color: Colors.white60)));
      spans.add(TextSpan(text: log.actionName, style: TextStyle(color: actionColor, fontWeight: FontWeight.bold)));
      if (actionParts.length > 1) {
        spans.add(TextSpan(text: actionParts[1], style: const TextStyle(color: Colors.white60)));
      }
    } else {
      spans.add(TextSpan(text: restOfText, style: const TextStyle(color: Colors.white60)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
        children: spans,
      ),
    );
  }

  Widget _buildHeroCardCombatant(HeroModel hero, int currentHp, {required bool isPlayer}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/hero', arguments: hero),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isPlayer ? Colors.greenAccent : Colors.redAccent).withAlpha(100),
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: CachedNetworkImage(imageUrl: hero.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 120,
            child: HpBar(
              currentHp: currentHp,
              maxHp: hero.maxHp,
              label: 'HP',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, BattleProvider battle, String label, String stats, Color color, {bool isRetreat = false}) {
    final bool canPress = battle.isPlayerTurn && !battle.isGameOver && !battle.isAwaitingSwitch;
    return ElevatedButton(
      onPressed: canPress ? () {
        if (isRetreat) {
          _showSwitchHeroDialog(context, battle);
        } else {
          battle.executeMove(label);
          if (!battle.isGameOver && !battle.isPlayerTurn && !battle.isAwaitingSwitch) {
            Future.delayed(const Duration(milliseconds: 1200), () => battle.aiTurn());
          }
        }
      } : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black87,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), 
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0)),
          const SizedBox(height: 2),
          Text(stats, 
            style: const TextStyle(fontSize: 8, color: Colors.black54, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showSwitchHeroDialog(BuildContext context, BattleProvider battle) {
    showModalBottomSheet(
      context: context,
      isDismissible: !battle.isAwaitingSwitch,
      enableDrag: !battle.isAwaitingSwitch,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(battle.isAwaitingSwitch ? 'YOUR HERO FAINTED! PICK A NEW ONE' : 'SELECT HERO TO SWAP', 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: battle.playerDeck.length,
                  itemBuilder: (context, i) {
                    final hero = battle.playerDeck[i];
                    final isCurrent = i == battle.currentPlayerIndex;
                    final isFainted = battle.faintedPlayerIndices.contains(i);
                    
                    return GestureDetector(
                      onTap: (!isCurrent && !isFainted) ? () {
                        battle.switchHero(i);
                        Navigator.pop(context);
                        if (!battle.isPlayerTurn) {
                           Future.delayed(const Duration(milliseconds: 1200), () => battle.aiTurn());
                        }
                      } : null,
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCurrent ? Colors.greenAccent : (isFainted ? Colors.red.withAlpha(100) : Colors.white24),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(imageUrl: hero.imageUrl, fit: BoxFit.cover),
                            ),
                            if (isFainted)
                              const Center(child: Icon(Icons.close, color: Colors.red, size: 40)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BattleIntroCountdown extends StatefulWidget {
  const BattleIntroCountdown({super.key});

  @override
  State<BattleIntroCountdown> createState() => _BattleIntroCountdownState();
}

class _BattleIntroCountdownState extends State<BattleIntroCountdown> {
  int _count = 3;
  Timer? _timer;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _isVisible = !_isVisible);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_count > 1) {
        if (mounted) setState(() => _count--);
      } else {
        _timer?.cancel();
        if (mounted) context.read<BattleProvider>().setIntroActive(false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: _isVisible ? 1.0 : 0.0,
        child: Text(
          '$_count',
          style: const TextStyle(fontSize: 180, fontWeight: FontWeight.w900, color: Colors.white, shadows: [
            Shadow(color: Colors.redAccent, blurRadius: 40),
            Shadow(color: Colors.blueAccent, blurRadius: 40),
          ]),
        ),
      ),
    );
  }
}

class BattleResultOverlay extends StatelessWidget {
  final String winner;
  final bool isPlayerWinner;
  final VoidCallback onClose;

  const BattleResultOverlay({
    super.key,
    required this.winner,
    required this.isPlayerWinner,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(200), // More translucent background
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPlayerWinner ? Icons.emoji_events : Icons.sentiment_very_dissatisfied, size: 100, color: isPlayerWinner ? Colors.amber : Colors.redAccent),
            const SizedBox(height: 20),
            Text(isPlayerWinner ? 'VICTORY' : 'DEFEAT', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: isPlayerWinner ? Colors.amber : Colors.redAccent, letterSpacing: 10)),
            const SizedBox(height: 10),
            Text(isPlayerWinner ? 'YOU ARE THE CHAMPION' : 'YOUR SQUAD HAS FALLEN', style: const TextStyle(color: Colors.white54, letterSpacing: 2)),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlayerWinner ? Colors.amber : Colors.redAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('RETURN TO BASE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
