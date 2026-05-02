import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/hero_model.dart';
import '../models/battle_record.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
  // Life Points
  int playerLp = 4000;
  int aiLp = 4000;

  // Decks
  List<HeroModel> playerDeck = [];
  List<HeroModel> aiDeck = [];

  // Hands
  List<HeroModel> playerHand = [];
  List<HeroModel> aiHand = [];

  // Fields (cards on battle field)
  List<HeroModel> playerField = [];
  List<HeroModel> aiField = [];

  bool battleInProgress = false;
  bool playerWon = false;
  bool isPlayerTurn = true;
  String battleLog = '';
  int round = 0;
  
  // Turn action tracking
  bool playerHasDrawnThisTurn = false;
  bool playerHasAttackedThisTurn = false;

  // 🃏 INIT YUGIOH BATTLE
  void initiateBattle(List<HeroModel> playerDeckInput, List<HeroModel> aiDeckInput) {
    playerDeck = List.from(playerDeckInput)..shuffle();
    aiDeck = List.from(aiDeckInput)..shuffle();

    playerLp = 4000;
    aiLp = 4000;

    playerHand = [];
    aiHand = [];
    playerField = [];
    aiField = [];

    battleInProgress = true;
    playerWon = false;
    
    round = 0;
    battleLog = '⚡ HERO BATTLE START!\n\n';

    // Draw initial 5 cards
    _drawCardsForPlayer(5);
    _drawCardsForAi(5);

    // Randomly decide who goes first (50/50 chance)
    isPlayerTurn = Random().nextBool();

    if (isPlayerTurn) {
      battleLog += '🟦 You go FIRST!\n';
      battleLog += '🟦 Draw 5 cards - Ready to play!\n';
      battleLog += '🟥 Opponent hand: 5 cards\n';
    } else {
      battleLog += '🟥 Opponent goes FIRST!\n';
      battleLog += '🟦 You draw 5 cards - Wait for opponent\'s turn!\n';
      battleLog += '🟥 Opponent hand: 5 cards\n';
    }
    
    battleLog += '\n🎲 First turn decided by coin flip!\n';
    
    _checkOutOfCards();

    notifyListeners();
  }

  // Draw cards from deck to hand
  void _drawCardsForPlayer(int count) {
    for (int i = 0; i < count && playerDeck.isNotEmpty; i++) {
      playerHand.add(playerDeck.removeAt(0));
    }
  }

  void _drawCardsForAi(int count) {
    for (int i = 0; i < count && aiDeck.isNotEmpty; i++) {
      aiHand.add(aiDeck.removeAt(0));
    }
  }

  // 🃏 DRAW CARD
  void drawCard() {
    if (!isPlayerTurn || !battleInProgress) return;
    
    // Check if already drew this turn
    if (playerHasDrawnThisTurn) {
      battleLog += '\n⚠️ You can only draw once per turn!\n';
      notifyListeners();
      return;
    }
    
    if (playerDeck.isEmpty) {
      battleLog += '\n⚠️ Your deck is empty! AUTO DEFEAT!\n';
      _endBattle(playerWon: false);
      notifyListeners();
      return;
    }

    final card = playerDeck.removeAt(0);
    playerHand.add(card);
    playerHasDrawnThisTurn = true;
    battleLog += '\n🟦 You drew: ${card.name}\n';
    
    _checkOutOfCards();
    notifyListeners();
  }

  // 🃏 PLAY CARD FROM HAND TO FIELD
  void playCard(int handIndex) {
    if (!isPlayerTurn || !battleInProgress || handIndex >= playerHand.length) return;

    final card = playerHand.removeAt(handIndex);
    playerField.add(card);
    battleLog += '\n🟦 You played: ${card.name} (ATK: ${card.attack})\n';
    notifyListeners();
  }

  // 🃏 ATTACK WITH A FIELD CARD
  void attackWithCard(int fieldIndex) {
    if (!isPlayerTurn || !battleInProgress || fieldIndex >= playerField.length) {
      return;
    }
    
    // Check if already attacked this turn
    if (playerHasAttackedThisTurn) {
      battleLog += '\n⚠️ You can only attack once per turn!\n';
      notifyListeners();
      return;
    }
    
    // Check if player has field cards
    if (playerField.isEmpty) {
      battleLog += '\n⚠️ You need a card on the field to attack!\n';
      notifyListeners();
      return;
    }
    
    playerHasAttackedThisTurn = true;
    if (aiField.isEmpty) {
      // Direct attack to LP
      final attackCard = playerField[fieldIndex];
      final damage = attackCard.attack;
      aiLp -= damage;

      battleLog +=
          '\n⚔️ ${attackCard.name} attacks directly for $damage damage!\n';
      battleLog += '🟥 Opponent LP: $aiLp\n';

      if (aiLp <= 0) {
        _endBattle(playerWon: true);
      }
    } else {
      // Attack opponent field card
      final attackCard = playerField[fieldIndex];
      final defendCard = aiField.first;

      battleLog +=
          '\n⚔️ ${attackCard.name} (${attackCard.attack}) vs ${defendCard.name} (${defendCard.attack})\n';

      if (attackCard.attack > defendCard.attack) {
        // Player card wins
        aiField.removeAt(0);
        final damage = attackCard.attack - defendCard.attack;
        aiLp -= damage;
        battleLog += '✅ ${defendCard.name} destroyed! Damage to LP: $damage\n';
        battleLog += '🟥 Opponent LP: $aiLp\n';
      } else if (attackCard.attack < defendCard.attack) {
        // AI card wins
        playerField.removeAt(fieldIndex);
        final damage = defendCard.attack - attackCard.attack;
        playerLp -= damage;
        battleLog += '❌ ${attackCard.name} destroyed! Damage to you: $damage\n';
        battleLog += '🟦 Your LP: $playerLp\n';
      } else {
        // Draw
        aiField.removeAt(0);
        playerField.removeAt(fieldIndex);
        battleLog += '💥 Both cards destroyed!\n';
      }

      if (playerLp <= 0) {
        _endBattle(playerWon: false);
      }
      if (aiLp <= 0) {
        _endBattle(playerWon: true);
      }
    }

    notifyListeners();
  }

  // 🃏 END TURN - AI's Turn
  Future<void> endTurn() async {
    if (!isPlayerTurn || !battleInProgress) return;

    isPlayerTurn = false;
    playerHasDrawnThisTurn = false;
    playerHasAttackedThisTurn = false;
    battleLog += '\n\n════════ END PLAYER TURN ════════\n';
    battleLog += '════════ AI TURN START ════════\n\n';

    notifyListeners();

    // AI plays
    await Future.delayed(const Duration(milliseconds: 1000));
    _aiPlayCards();
    await Future.delayed(const Duration(milliseconds: 1000));
    _aiAttack();
    await Future.delayed(const Duration(milliseconds: 1000));

    // Switch back to player turn
    isPlayerTurn = true;
    playerHasDrawnThisTurn = false;
    playerHasAttackedThisTurn = false;
    
    // Check if player is out of cards
    if (!_checkOutOfCards()) {
      battleLog += '\n════════ YOUR TURN ════════\n';
      battleLog += '🟦 Draw a card or play from hand!\n';
    }

    notifyListeners();
  }

  // 🃏 AI LOGIC - Play cards
  void _aiPlayCards() {
    // AI plays up to 2 cards from hand
    int cardsPlayed = 0;
    while (aiHand.isNotEmpty && aiField.length < 3 && cardsPlayed < 2) {
      final card = aiHand.removeAt(0);
      aiField.add(card);
      battleLog += '🟥 Opponent played: ${card.name} (ATK: ${card.attack})\n';
      cardsPlayed++;
    }
  }

  // 🃏 AI LOGIC - Attack
  void _aiAttack() {
    if (aiField.isEmpty) return;

    for (var attackCard in aiField) {
      if (playerField.isEmpty) {
        // Direct attack
        final damage = attackCard.attack;
        playerLp -= damage;
        battleLog +=
            '🟥 ${attackCard.name} attacks directly for $damage damage!\n';
        battleLog += '🟦 Your LP: $playerLp\n';
      } else {
        // Attack first player card
        final defendCard = playerField.first;

        if (attackCard.attack > defendCard.attack) {
          playerField.removeAt(0);
          final damage = attackCard.attack - defendCard.attack;
          playerLp -= damage;
          battleLog +=
              '🟥 ${attackCard.name} destroys ${defendCard.name}! Damage: $damage\n';
          battleLog += '🟦 Your LP: $playerLp\n';
        } else if (attackCard.attack < defendCard.attack) {
          // AI card destroyed
          battleLog +=
              '🟦 Your ${defendCard.name} destroys ${attackCard.name}!\n';
        } else {
          battleLog += '💥 ${defendCard.name} and ${attackCard.name} destroyed!\n';
          playerField.removeAt(0);
        }
      }

      if (playerLp <= 0) {
        _endBattle(playerWon: false);
        return;
      }
    }
  }

  // 🃏 END BATTLE
  Future<void> _endBattle({required bool playerWon}) async {
    battleInProgress = false;
    this.playerWon = playerWon;

    if (playerWon) {
      battleLog += '\n\n🏆 YOU WIN! 🏆\n';
    } else {
      battleLog += '\n\n💀 YOU LOSE! 💀\n';
    }

    // Save battle record
    try {
      final record = BattleRecord(
        playerHero: 'Yu-Gi-Oh Battle',
        aiHero: 'Yu-Gi-Oh Battle',
        playerWon: playerWon,
        roundsPlayed: round,
        playedAt: DateTime.now().toIso8601String(),
      );
      await DatabaseService().saveBattleRecord(record);
    } catch (e) {
      battleLog += 'Error saving battle: $e\n';
    }

    notifyListeners();
  }

  // 🃏 CHECK IF PLAYER IS OUT OF CARDS
  bool _checkOutOfCards() {
    if (playerDeck.isEmpty && playerHand.isEmpty) {
      battleLog += '\n\n💀 OUT OF CARDS! AUTO DEFEAT! 💀\n';
      _endBattle(playerWon: false);
      return true;
    }
    return false;
  }

  // Getters
  int get playerHandSize => playerHand.length;
  int get aiHandSize => aiHand.length;
  int get playerFieldSize => playerField.length;
  int get aiFieldSize => aiField.length;
  int get playerDeckSize => playerDeck.length;
  int get aiDeckSize => aiDeck.length;
}