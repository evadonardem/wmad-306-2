import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/player_provider.dart';

class BattleScreen extends StatefulWidget {
  final List<HeroModel> playerDeck;
  final List<HeroModel> aiDeck;

  const BattleScreen({
    super.key,
    required this.playerDeck,
    required this.aiDeck,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  int? selectedHandCard;
  int? selectedFieldCard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<BattleProvider>()
          .initiateBattle(widget.playerDeck, widget.aiDeck);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ HERO BATTLE ⚡'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[900],
        elevation: 0,
      ),
      body: Consumer<BattleProvider>(
        builder: (context, battle, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple[900]!,
                  Colors.indigo[900]!,
                  Colors.blue[900]!,
                ],
              ),
            ),
            child: Column(
              children: [
                // Opponent Status Bar
                _buildStatusBar(
                  name: 'OPPONENT',
                  hp: battle.aiLp,
                  maxHp: 3000,
                  isOpponent: true,
                  deckCount: battle.aiDeckSize,
                ),

                // Battle Arena - Opponent Side
                _buildArena(
                  cards: battle.aiField,
                  isOpponent: true,
                  onCardTap: (index) {},
                ),

                // VS Badge & Battle Log
                _buildVsBadge(battle: battle),

                // Battle Arena - Player Side
                _buildArena(
                  cards: battle.playerField,
                  isOpponent: false,
                  selectedIndex: selectedFieldCard,
                  onCardTap: (index) {
                    setState(() {
                      selectedFieldCard = selectedFieldCard == index ? null : index;
                    });
                  },
                ),

                // Player Status Bar
                _buildStatusBar(
                  name: 'YOU',
                  hp: battle.playerLp,
                  maxHp: 3000,
                  isOpponent: false,
                  deckCount: battle.playerDeckSize,
                ),

                // Hand Cards - Modern Style
                _buildHandSection(
                  battle: battle,
                  selectedHandCard: selectedHandCard,
                  onCardTap: (index) {
                    setState(() {
                      selectedHandCard = selectedHandCard == index ? null : index;
                    });
                  },
                  onPlay: (index) {
                    battle.playCard(index);
                    setState(() {
                      selectedHandCard = null;
                    });
                  },
                ),

                // Modern Action Bar
                _buildActionBar(
                  battle: battle,
                  selectedFieldCard: selectedFieldCard,
                  onDraw: () => battle.drawCard(),
                  onAttack: selectedFieldCard != null
                      ? () {
                          battle.attackWithCard(selectedFieldCard!);
                          setState(() {
                            selectedFieldCard = null;
                          });
                        }
                      : null,
                  onEndTurn: () => battle.endTurn(),
                  onReturn: () {
                    if (battle.playerWon) {
                      context.read<PlayerProvider>().incrementWins();
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Status Bar with HP
  Widget _buildStatusBar({
    required String name,
    required int hp,
    required int maxHp,
    required bool isOpponent,
    required int deckCount,
  }) {
    final color = isOpponent ? Colors.red : Colors.blue;
    final hpPercent = hp / maxHp;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(100),
        border: Border(
          bottom: BorderSide(color: color.withAlpha(100), width: 2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 1),
            ),
            child: Text(
              name,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HP: $hp/$maxHp',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Deck: $deckCount',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: hpPercent.clamp(0.0, 1.0),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withAlpha(200),
                            color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Battle Arena
  Widget _buildArena({
    required List<HeroModel> cards,
    required bool isOpponent,
    int? selectedIndex,
    required Function(int) onCardTap,
  }) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOpponent ? Colors.red.withAlpha(50) : Colors.blue.withAlpha(50),
          width: 2,
        ),
      ),
      child: cards.isEmpty
          ? Center(
              child: Text(
                isOpponent ? 'Opponent Field Empty' : 'Your Field - Play a card!',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                final isSelected = selectedIndex == index;
                return _buildHeroCard(
                  card: card,
                  isOpponent: isOpponent,
                  isSelected: isSelected,
                  onTap: () => onCardTap(index),
                );
              },
            ),
    );
  }

  // Modern Hero Card
  Widget _buildHeroCard({
    required HeroModel card,
    required bool isOpponent,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final accentColor = isOpponent ? Colors.red : Colors.blue;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.yellow : accentColor.withAlpha(150),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? Colors.yellow : accentColor).withAlpha(100),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Hero Image
              Image.network(
                card.imageUrl,
                height: 100,
                width: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      height: 100,
                      width: 90,
                      color: Colors.grey[800],
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
              ),
              // Gradient Overlay
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(200),
                    ],
                  ),
                ),
              ),
              // Stats Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatBadge('⚔️', card.attack, Colors.orange),
                          _buildStatBadge('❤️', card.maxHp, Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Selection indicator
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String icon, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(180),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$icon$value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // VS Badge
  Widget _buildVsBadge({required BattleProvider battle}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.yellow, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withAlpha(100),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Text(
              'VS',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          if (battle.battleLog.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                battle.battleLog.split('\n').last,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Hand Section
  Widget _buildHandSection({
    required BattleProvider battle,
    required int? selectedHandCard,
    required Function(int) onCardTap,
    required Function(int) onPlay,
  }) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(80),
        border: Border(
          top: BorderSide(color: Colors.blue.withAlpha(100), width: 2),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Hand',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (selectedHandCard != null)
                  ElevatedButton.icon(
                    onPressed: battle.isPlayerTurn && battle.battleInProgress
                        ? () => onPlay(selectedHandCard)
                        : null,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('PLAY'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: battle.playerHand.isEmpty
                ? Center(
                    child: Text(
                      'No cards in hand',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: battle.playerHand.length,
                    itemBuilder: (context, index) {
                      final card = battle.playerHand[index];
                      final isSelected = selectedHandCard == index;
                      return _buildHandCard(
                        card: card,
                        isSelected: isSelected,
                        onTap: () => onCardTap(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandCard({
    required HeroModel card,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.cyan : Colors.blue.withAlpha(150),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? Colors.cyan : Colors.blue).withAlpha(100),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.network(
                card.imageUrl,
                height: 95,
                width: 85,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      height: 95,
                      width: 85,
                      color: Colors.grey[800],
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
              ),
              Container(
                height: 95,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(180),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatBadge('⚔️', card.attack, Colors.orange),
                          _buildStatBadge('❤️', card.maxHp, Colors.red),
                        ],
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
  }

  // Action Bar
  Widget _buildActionBar({
    required BattleProvider battle,
    required int? selectedFieldCard,
    required VoidCallback onDraw,
    required VoidCallback? onAttack,
    required VoidCallback onEndTurn,
    required VoidCallback onReturn,
  }) {
    if (!battle.battleInProgress) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(100),
          border: Border(
            top: BorderSide(
              color: battle.playerWon ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: battle.playerWon
                      ? [Colors.green.withAlpha(100), Colors.green.withAlpha(50)]
                      : [Colors.red.withAlpha(100), Colors.red.withAlpha(50)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: battle.playerWon ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    battle.playerWon ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
                    color: battle.playerWon ? Colors.yellow : Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    battle.playerWon ? 'VICTORY!' : 'DEFEAT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: battle.playerWon ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onReturn,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Return to Deck'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(100),
        border: Border(
          top: BorderSide(color: Colors.blue.withAlpha(100), width: 2),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_circle,
                label: 'DRAW',
                color: Colors.cyan,
                onPressed: battle.isPlayerTurn ? onDraw : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: Icons.flash_on,
                label: 'ATTACK',
                color: Colors.orange,
                onPressed: (battle.isPlayerTurn && onAttack != null) ? onAttack : null,
                isHighlighted: onAttack != null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: Icons.skip_next,
                label: 'END TURN',
                color: Colors.green,
                onPressed: battle.isPlayerTurn ? onEndTurn : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    bool isHighlighted = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null ? color : Colors.grey[800],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isHighlighted ? 8 : 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}


