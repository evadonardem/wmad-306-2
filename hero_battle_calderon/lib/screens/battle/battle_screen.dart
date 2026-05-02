import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../models/hero_model.dart';
import '../../models/battle_record.dart';
import '../../providers/player_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/hero_image.dart';
import '../../widgets/hp_bar.dart';

class BattleEntity {
  final HeroModel hero;
  final bool isPlayer;
  double actionValue; // Distance to next turn
  int currentHp;
  int maxHp;

  // Combat State / Buffs
  int currentSpeed;
  int speedBuffTurns = 0;
  int extraDamage = 0;
  int damageReductionHits = 0;
  double critChanceBonus = 0.0;
  double critDamageBonus = 0.0;
  bool receivedActionAdvance = false;
  double tauntValue = 1.0; // Default weight for being targeted
  bool isPerformingAction = false;
  bool isReceivingAction = false;
  bool isTakingDamage = false;
  Color performingActionColor = Colors.white;
  Color receivingActionColor = Colors.white;

  BattleEntity({
    required this.hero,
    required this.isPlayer,
    required this.actionValue,
  }) : currentHp = hero.maxHp,
       maxHp = hero.maxHp,
       currentSpeed = math.max(1, hero.powerStats.speed);

  // AV = 10000 / Speed
  double get baseActionValue {
    return 10000 / currentSpeed;
  }

  bool get isDead => currentHp <= 0;
}

class BattleScreen extends StatefulWidget {
  final List<HeroModel> playerTeam;
  final List<HeroModel> aiTeam;
  final String aiName;

  const BattleScreen({
    super.key,
    required this.playerTeam,
    required this.aiTeam,
    required this.aiName,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  late AnimationController _actionTimerController;
  List<BattleEntity> timeline = [];
  List<BattleEntity> playerEntities = [];
  List<BattleEntity> aiEntities = [];
  List<String> battleLog = [];
  bool isBattleOver = false;
  String? winner;

  String currentActionMessage = "";
  String? currentActionType;
  bool showActionMessage = false;
  bool _recordSaved = false;

  // Targeting and Hover State
  String? selectedAction;
  BattleEntity? hoveredEntity;
  String? hoveredActionButton;

  @override
  void initState() {
    super.initState();
    _actionTimerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _initializeBattle();
    battleLog.add("Battle Start! Order determined by Speed.");

    // If first actor is AI, trigger their turn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (timeline.isNotEmpty && !timeline.first.isPlayer) {
        _handleAiTurn();
      }
    });
  }

  @override
  void dispose() {
    _actionTimerController.dispose();
    super.dispose();
  }

  void _initializeBattle() {
    timeline = [];
    playerEntities = [];
    aiEntities = [];

    // Initialize player heroes
    for (var hero in widget.playerTeam) {
      final speed = math.max(1, hero.powerStats.speed);
      final entity = BattleEntity(
        hero: hero,
        isPlayer: true,
        actionValue: 10000 / speed,
      );
      playerEntities.add(entity);
      timeline.add(entity);
    }
    // Initialize AI heroes
    for (var hero in widget.aiTeam) {
      final speed = math.max(1, hero.powerStats.speed);
      final entity = BattleEntity(
        hero: hero,
        isPlayer: false,
        actionValue: 10000 / speed,
      );
      aiEntities.add(entity);
      timeline.add(entity);
    }
    _sortTimeline();
  }

  void _sortTimeline() {
    timeline.sort((a, b) => a.actionValue.compareTo(b.actionValue));
  }

  @override
  Widget build(BuildContext context) {
    final isEnemyTurn = !isBattleOver && timeline.isNotEmpty && !timeline.first.isPlayer && !showActionMessage;
    final playerName = context.watch<PlayerProvider>().playerName;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1D1A),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (isEnemyTurn)
                  Container(
                    width: double.infinity,
                    color: Colors.red.withAlpha(50),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Text(
                      "ENEMY IS THINKING...",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
                    ),
                  ),
                const SizedBox(height: 20),
                _buildTeamRow(aiEntities, widget.aiName, isPlayer: false),
                
                const Spacer(),
                if (showActionMessage)
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionMessageText(),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: AnimatedBuilder(
                              animation: _actionTimerController,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  value: 1.0 - _actionTimerController.value,
                                  backgroundColor: Colors.white10,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    timeline.isNotEmpty && timeline.first.isPlayer ? Colors.blueAccent : Colors.redAccent,
                                  ),
                                  minHeight: 4,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),

                _buildTeamRow(playerEntities, playerName, isPlayer: true),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 20),
                _buildTimelineBar(),
                const SizedBox(height: 20),
              ],
            ),
            Positioned(
              left: 16,
              bottom: 100,
              child: MouseRegion(
                onEnter: (_) => setState(() => hoveredActionButton = "Guide"),
                onExit: (_) => setState(() => hoveredActionButton = null),
                child: AnimatedOpacity(
                  opacity: hoveredActionButton == "Guide" ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: FloatingActionButton.small(
                    onPressed: () => _showHelpDialog(context),
                    backgroundColor: const Color(0xFF2C2A26),
                    shape: CircleBorder(side: BorderSide(color: Colors.white.withOpacity(0.1))),
                    child: const Icon(Icons.help_outline, color: Colors.white70),
                  ),
                ),
              ),
            ),
            if (isBattleOver) _buildGameOverOverlay(playerName),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const BattleHelpDialog(),
    );
  }

  Widget _buildTeamRow(List<BattleEntity> entities, String label, {required bool isPlayer}) {
    if (timeline.isEmpty) return const SizedBox();
    final currentActor = timeline.first;
    
    return Column(
      crossAxisAlignment: isPlayer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            final entity = index < entities.length ? entities[index] : null;
            if (entity == null) {
              return SizedBox(
                width: 90, 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.asset(
                          'assets/emptyCard.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.help_outline, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(height: 34), // HP bar spacer
                    const SizedBox(height: 25), // Buff row spacer
                  ],
                ),
              );
            }

            final isActing = !isBattleOver && currentActor == entity;
            final isPerforming = entity.isPerformingAction;
            final isReceiving = entity.isReceivingAction;
            final isTargetable = _isEntityTargetable(entity);
            final isHighlightedByDefend = hoveredActionButton == "Defend" && entity.isPlayer && !entity.isDead;
            final isHovered = hoveredEntity == entity;
            
            Color borderColor = isActing ? Colors.white : (entity.isDead ? Colors.red : Colors.grey.withValues(alpha: 0.5));
            if (isPerforming) borderColor = entity.performingActionColor;
            if (isReceiving) borderColor = entity.receivingActionColor;
            
            if (!isBattleOver) {
              if (isHovered) {
                borderColor = Colors.yellow;
              } else if (isTargetable) {
                borderColor = entity.isPlayer ? Colors.greenAccent : Colors.redAccent;
              } else if (isHighlightedByDefend) {
                borderColor = Colors.blueAccent;
              }
            }

            final hero = entity.hero;
            
            return MouseRegion(
              onEnter: (_) => setState(() => hoveredEntity = entity),
              onExit: (_) => setState(() => hoveredEntity = null),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (isTargetable) {
                    _executeAction(currentActor, selectedAction!, entity);
                    setState(() => selectedAction = null);
                  } else {
                    _showHeroDetails(context, hero);
                  }
                },
                child: Opacity(
                  opacity: entity.isDead ? 0.5 : 1.0,
                  child: SizedBox(
                    width: 90,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: borderColor,
                              width: (isActing || isHovered || isTargetable || isHighlightedByDefend || isPerforming || isReceiving) ? 4 : 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: (isTargetable || isHighlightedByDefend || isPerforming || isReceiving) ? [
                              BoxShadow(color: borderColor.withAlpha(150), blurRadius: 12, spreadRadius: 2)
                            ] : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                HeroImage(
                                  urls: [hero.imageUrl, hero.akababImageUrl],
                                  heroId: hero.id,
                                  heroName: hero.name,
                                  searchTerms: hero.aliases,
                                  fit: BoxFit.cover,
                                  loading: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  error: const Icon(Icons.error, color: Colors.red, size: 20),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: Colors.black54,
                                    child: Text(
                                      hero.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 8),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate(
                          target: (isPerforming || isReceiving) ? 1 : 0,
                        ).custom(
                          duration: 400.ms,
                          builder: (context, value, child) {
                            if (!isPerforming && !isReceiving) return child;
                            final glowColor = isPerforming ? entity.performingActionColor : entity.receivingActionColor;
                            
                            // subtle glow for performer, intense for receiver
                            final blur = isReceiving ? 40.0 : 12.0;
                            final spread = isReceiving ? 15.0 : 4.0;
                            final opacity = isReceiving ? 1.0 : 0.6;

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: glowColor.withOpacity(opacity * (1 - value)),
                                    blurRadius: blur * value,
                                    spreadRadius: spread * value,
                                  )
                                ],
                              ),
                              child: child,
                            );
                          },
                        ).scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                          curve: Curves.elasticOut,
                        ).then().scale(
                          begin: const Offset(1.1, 1.1),
                          end: const Offset(1, 1),
                          curve: Curves.easeInOut,
                        ).animate(
                          target: entity.isTakingDamage ? 1 : 0,
                        ).shake(
                          duration: 250.ms,
                          hz: 2,
                          offset: const Offset(3, 0),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 34,
                                child: HpBar(
                                  currentHp: entity.currentHp,
                                  maxHp: entity.maxHp,
                                  label: "", // Compact
                                ),
                              ),
                              // Buff icons row
                              if (!entity.isDead)
                                SizedBox(
                                  height: 25,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (entity.receivedActionAdvance)
                                        _buildBuffIcon(Icons.forward_10, "Action Advance", Colors.cyanAccent),
                                      if (entity.extraDamage > 0)
                                        _buildBuffIcon(Icons.fitness_center, "Damage Boost", Colors.orangeAccent),
                                      if (entity.speedBuffTurns > 0)
                                        _buildBuffIcon(Icons.speed, "SPD Buff", Colors.greenAccent),
                                      if (entity.damageReductionHits > 0)
                                        _buildBuffIcon(Icons.shield, "Shield/DR", Colors.blueAccent),
                                      if (entity.critChanceBonus > 0)
                                        _buildBuffIcon(Icons.auto_awesome, "Crit Chance", Colors.yellowAccent),
                                      if (entity.critDamageBonus > 0)
                                        _buildBuffIcon(Icons.ads_click, "Crit Dmg Buff", Colors.redAccent),
                                    ],
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
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActionMessageText() {
    final style = const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
    );

    if (currentActionType == null) {
      return Text(currentActionMessage, style: style, textAlign: TextAlign.center);
    }

    String actionWord = "";
    Color actionColor = Colors.white;

    if (currentActionType == "Attack") {
      actionWord = "attacks";
      actionColor = Colors.red;
    } else if (currentActionType == "Defend") {
      actionWord = "defends";
      actionColor = Colors.blue;
    } else if (currentActionType == "Support") {
      actionWord = "Support";
      actionColor = Colors.green;
    }

    // Try to find the action word in the message
    // If "attacks" isn't found (e.g. "uses Attack!"), check for "Attack"
    if (!currentActionMessage.contains(actionWord) && currentActionType == "Attack") {
      actionWord = "Attack";
    }

    if (!currentActionMessage.contains(actionWord)) {
      return Text(currentActionMessage, style: style, textAlign: TextAlign.center);
    }

    final parts = currentActionMessage.split(actionWord);
    List<TextSpan> spans = [];
    
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i], style: style));
      if (i < parts.length - 1) {
        spans.add(TextSpan(
          text: actionWord,
          style: style.copyWith(color: actionColor, decoration: TextDecoration.underline),
        ));
      }
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: spans),
    );
  }

  Widget _buildBuffIcon(IconData icon, String label, Color color) {
    return Tooltip(
      message: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: Icon(icon, color: color, size: 14),
      ),
    );
  }

  bool _isEntityTargetable(BattleEntity target) {
    if (selectedAction == null || target.isDead) return false;
    final actor = timeline.first;
    if (target == actor) return false; // Cannot target self

    if (selectedAction == "Attack" && !target.isPlayer) return true;
    if (selectedAction == "Support" && target.isPlayer) return true;
    return false;
  }

  void _onActionButtonTap(String action) {
    if (isBattleOver || showActionMessage) return;
    
    if (action == "Defend") {
      _executeAction(timeline.first, "Defend", null);
    } else {
      setState(() {
        if (selectedAction == action) {
          selectedAction = null;
        } else {
          selectedAction = action;
        }
      });
    }
  }

  void _showHeroDetails(BuildContext context, HeroModel hero) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 150,
                          height: 200,
                          child: HeroImage(
                            urls: [hero.imageUrl, hero.akababImageUrl],
                            heroId: hero.id,
                            heroName: hero.name,
                            searchTerms: hero.aliases,
                            fit: BoxFit.cover,
                            loading: const Center(child: CircularProgressIndicator()),
                            error: const Icon(Icons.error, size: 50, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(hero.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(hero.fullName, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey)),
                      const SizedBox(height: 24),
                      
                      _buildDetailSection(
                        title: 'Power Stats',
                        icon: Icons.bar_chart,
                        color: Colors.blue,
                        children: [
                          _buildStatRow('Intelligence', hero.powerStats.intelligence, Colors.blue, Icons.psychology),
                          _buildStatRow('Strength', hero.powerStats.strength, Colors.red, Icons.fitness_center),
                          _buildStatRow('Speed', hero.powerStats.speed, Colors.green, Icons.speed),
                          _buildStatRow('Durability', hero.powerStats.durability, Colors.orange, Icons.shield),
                          _buildStatRow('Power', hero.powerStats.power, Colors.purple, Icons.bolt),
                          _buildStatRow('Combat', hero.powerStats.combat, Colors.brown, Icons.sports_martial_arts),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection({required String title, required IconData icon, required Color color, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        initiallyExpanded: title == 'Power Stats',
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.withAlpha(200)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value / 100,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(color: color.withAlpha(100), blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 25,
            child: Text(
              value.toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
      dense: true,
    );
  }


  Widget _buildActionButtons() {
    if (timeline.isEmpty || isBattleOver) return const SizedBox(height: 135);
    final currentActor = timeline.first;
    final isPlayerTurn = currentActor.isPlayer && !showActionMessage;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton("Defend", "assets/Defend.png", isPlayerTurn),
            const SizedBox(width: 20),
            _buildActionButton("Support", "assets/Support.png", isPlayerTurn),
          ],
        ),
        const SizedBox(height: 15),
        _buildActionButton("Attack", "assets/Attack.png", isPlayerTurn, wide: true),
      ],
    );
  }

  Widget _buildActionButton(String label, String assetPath, bool enabled, {bool wide = false}) {
    final isSelected = selectedAction == label;
    final isHovered = hoveredActionButton == label;
    
    return MouseRegion(
      onEnter: (_) => setState(() => hoveredActionButton = label),
      onExit: (_) => setState(() => hoveredActionButton = null),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Container(
        width: wide ? 240 : 170,
        height: 60,
        decoration: BoxDecoration(
          color: (isSelected || (isHovered && enabled)) ? Colors.white24 : (enabled ? const Color(0xFF1E1E1E) : Colors.black),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : (enabled ? Colors.white : Colors.grey), 
            width: isSelected ? 3 : 2
          ),
          boxShadow: (isHovered && enabled) ? [
            BoxShadow(color: Colors.white.withAlpha(30), blurRadius: 10, spreadRadius: 2)
          ] : null,
        ),
        child: InkWell(
          onTap: enabled ? () => _onActionButtonTap(label) : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: enabled ? Colors.white : Colors.grey,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(assetPath, width: 32, height: 32, color: enabled ? Colors.white : Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineBar() {
    final displayTimeline = timeline.where((e) => !e.isDead).take(8).toList();
    if (displayTimeline.isEmpty) return const SizedBox(height: 60);

    final currentActor = displayTimeline.first;
    final futureActors = displayTimeline.skip(1).toList();
    
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                HeroImage(
                  urls: [currentActor.hero.imageUrl, currentActor.hero.akababImageUrl],
                  heroId: currentActor.hero.id,
                  heroName: currentActor.hero.name,
                  searchTerms: currentActor.hero.aliases,
                  fit: BoxFit.cover,
                  loading: const SizedBox(),
                  error: const Icon(Icons.error, size: 10),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    color: Colors.black87,
                    child: const Text(
                      "NOW",
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_left, color: Colors.white, size: 28),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: futureActors.length,
              itemBuilder: (context, index) {
                final entity = futureActors[index];
                return Container(
                  width: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: entity.isPlayer ? Colors.blue : Colors.red,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      HeroImage(
                        urls: [entity.hero.imageUrl, entity.hero.akababImageUrl],
                        heroId: entity.hero.id,
                        heroName: entity.hero.name,
                        searchTerms: entity.hero.aliases,
                        fit: BoxFit.cover,
                        loading: const SizedBox(),
                        error: const Icon(Icons.error, size: 10),
                      ),
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


  void _executeAction(BattleEntity actor, String action, BattleEntity? target) {
    if (isBattleOver || showActionMessage) return;

    String message = "${actor.hero.name} uses $action!";
    
    setState(() {
      actor.isPerformingAction = true;
      actor.tauntValue = 1.0; // Reset taunt on their new turn
      
      // Clear one-time status from receiving support at the start of action
      actor.receivedActionAdvance = false;

      if (action == "Attack") {
        currentActionType = "Attack";
        actor.performingActionColor = Colors.red;
        if (target != null) {
          final res = _calculateDamage(actor, target);
          final damage = res['damage'] as int;
          final isCrit = res['isCrit'] as bool;
          
          target.currentHp = math.max(0, target.currentHp - damage);
          target.isTakingDamage = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() => target!.isTakingDamage = false);
          });
          
          message = "${actor.hero.name} attacks ${target.hero.name} for $damage damage!";
          if (isCrit) message = "CRITICAL HIT! $message";
          if (target.isDead) message += " ${target.hero.name} is defeated!";
          
          // Consume hit-based buffs
          if (target.damageReductionHits > 0) target.damageReductionHits--;
          actor.extraDamage = 0;
          actor.critChanceBonus = 0;
          actor.critDamageBonus = 0;
        }
      } else if (action == "Defend") {
        currentActionType = "Defend";
        actor.performingActionColor = Colors.blue;
        actor.tauntValue = 5.0; // Significant increase in taunt level
        message = "${actor.hero.name} defends and is on guard!";
      } else if (action == "Support") {
        currentActionType = "Support";
        actor.performingActionColor = Colors.green;
        if (target != null) {
          target.isReceivingAction = true;
          target.receivingActionColor = Colors.green;
          final highestStat = _getHighestStat(actor.hero);
          if (highestStat == 'Intelligence') {
            target.actionValue *= 0.75;
            target.receivedActionAdvance = true;
            message = "${actor.hero.name} uses Support! ${target.hero.name}'s turn is pushed forward!";
          } else if (highestStat == 'Strength') {
            target.extraDamage = (actor.hero.powerStats.strength * 0.5).round();
            message = "${actor.hero.name} uses Support! ${target.hero.name}'s next attack is empowered!";
          } else if (highestStat == 'Speed') {
            target.currentSpeed = (target.hero.powerStats.speed * 1.3).round();
            target.speedBuffTurns = 2;
            message = "${actor.hero.name} uses Support! ${target.hero.name}'s Speed increased!";
          } else if (highestStat == 'Durability') {
            target.damageReductionHits = 2;
            message = "${actor.hero.name} uses Support! ${target.hero.name} is fortified!";
          } else if (highestStat == 'Power') {
            target.critChanceBonus = 0.5;
            message = "${actor.hero.name} uses Support! ${target.hero.name}'s Crit Chance boosted!";
          } else if (highestStat == 'Combat') {
            target.critDamageBonus = 0.25;
            message = "${actor.hero.name} uses Support! ${target.hero.name}'s Crit Damage boosted!";
          }
        }
      }

      currentActionMessage = message;
      showActionMessage = true;
      battleLog.add(message);
      _actionTimerController.reset();
      _actionTimerController.forward();
    });

    // Handle speed buff decay for the actor
    if (actor.speedBuffTurns > 0) {
      actor.speedBuffTurns--;
      if (actor.speedBuffTurns == 0) {
        actor.currentSpeed = math.max(1, actor.hero.powerStats.speed);
      }
    }

    // Timeline logic
    timeline.removeAt(0);
    double usedAV = actor.actionValue;
    for (var e in timeline) {
      e.actionValue -= usedAV;
    }
    actor.actionValue = actor.baseActionValue;
    timeline.add(actor);
    
    _sortTimeline();
    _checkBattleEnd();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          actor.isPerformingAction = false;
          for (var e in playerEntities) { e.isReceivingAction = false; }
          for (var e in aiEntities) { e.isReceivingAction = false; }
          showActionMessage = false;
        });
        if (!isBattleOver) _processNextTurn();
      }
    });
  }

  String _getHighestStat(HeroModel hero) {
    final stats = {
      'Intelligence': hero.powerStats.intelligence,
      'Strength': hero.powerStats.strength,
      'Speed': hero.powerStats.speed,
      'Durability': hero.powerStats.durability,
      'Power': hero.powerStats.power,
      'Combat': hero.powerStats.combat,
    };
    
    int maxVal = stats.values.reduce(math.max);
    List<String> maxKeys = [];
    stats.forEach((key, value) {
      if (value == maxVal) maxKeys.add(key);
    });
    
    return maxKeys[math.Random().nextInt(maxKeys.length)];
  }

  void _handleAction(String action) {
    // Legacy support
  }

  void _processNextTurn() {
    // Skip dead actors
    while (timeline.isNotEmpty && timeline.first.isDead) {
      final deadActor = timeline.removeAt(0);
      deadActor.actionValue = 999999; // Effectively out
      timeline.add(deadActor);
      _sortTimeline();
    }

    if (timeline.isNotEmpty && !timeline.first.isPlayer) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && !isBattleOver) _handleAiTurn();
      });
    }
  }

  void _handleAiTurn() {
    if (isBattleOver) return;
    final actor = timeline.first;
    
    final rng = math.Random().nextDouble();
    String aiAction;
    BattleEntity? target;
    
    if (rng < 0.70) {
      aiAction = "Attack";
      final targets = playerEntities.where((e) => !e.isDead).toList();
      if (targets.isNotEmpty) {
        // Weighted targeting based on Taunt level
        double totalTaunt = targets.fold(0, (sum, e) => sum + e.tauntValue);
        double pick = math.Random().nextDouble() * totalTaunt;
        double currentSum = 0;
        for (var t in targets) {
          currentSum += t.tauntValue;
          if (pick <= currentSum) {
            target = t;
            break;
          }
        }
        target ??= targets.last;
      }
    } else if (rng < 0.85) {
      aiAction = "Support";
      final allies = aiEntities.where((e) => !e.isDead).toList();
      if (allies.isNotEmpty) target = allies[math.Random().nextInt(allies.length)];
    } else {
      aiAction = "Defend";
    }
    
    _executeAction(actor, aiAction, target);
  }

  Map<String, dynamic> _calculateDamage(BattleEntity attacker, BattleEntity defender) {
    final rng = math.Random();
    
    // Crit logic
    double critChance = 0.05 + attacker.critChanceBonus;
    bool isCrit = rng.nextDouble() < critChance;
    double critMult = 1.25 + attacker.critDamageBonus;
    
    int rawDamage = attacker.hero.attack;
    if (isCrit) {
      rawDamage = (rawDamage * critMult).round();
    }
    
    int damage = math.max(10, rawDamage - (defender.hero.defense / 2).round());
    
    // Strength buff
    damage += attacker.extraDamage;
    
    // Random variance
    damage = (damage * (0.8 + rng.nextDouble() * 0.4)).round();
    
    // Apply 10% damage reduction as requested
    damage = (damage * 0.9).round();
    
    // Durability buff
    if (defender.damageReductionHits > 0) {
      damage = (damage * 0.6).round();
    }
    
    return {
      'damage': math.max(1, damage),
      'isCrit': isCrit,
    };
  }

  void _checkBattleEnd() {
    if (isBattleOver) return;

    final playerName = context.read<PlayerProvider>().playerName;

    if (playerEntities.every((e) => e.isDead)) {
      setState(() {
        isBattleOver = true;
        winner = widget.aiName;
      });
    } else if (aiEntities.every((e) => e.isDead)) {
      setState(() {
        isBattleOver = true;
        winner = playerName;
      });
    }

    if (isBattleOver && !_recordSaved) {
      _recordSaved = true;
      final record = BattleRecord(
        aiName: widget.aiName,
        playerTeam: playerEntities.map((e) => e.hero.name).toList(),
        aiTeam: aiEntities.map((e) => e.hero.name).toList(),
        playerWon: winner == playerName,
        roundsPlayed: 0, // Not tracked yet, but field exists
        playedAt: DateTime.now().toIso8601String(),
      );
      DatabaseService().saveBattleRecord(record);
    }
  }

  Widget _buildGameOverOverlay(String playerName) {
    final isPlayerWinner = winner == playerName;
    return Container(
      color: Colors.black87,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isPlayerWinner ? "VICTORY" : "DEFEAT",
            style: TextStyle(
              color: isPlayerWinner ? Colors.green : Colors.red,
              fontSize: 60,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "$winner HAS WON THE BATTLE!",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            isPlayerWinner ? "Your team has conquered the enemies!" : "The enemy team was too strong this time.",
            style: const TextStyle(color: Colors.white70, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            child: const Text("RETURN TO HOME"),
          ),
        ],
      ),
    );
  }
}

class BattleHelpDialog extends StatelessWidget {
  const BattleHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Row(
        children: [
          Icon(Icons.help_outline, color: Colors.blueAccent),
          SizedBox(width: 10),
          Text("Battle Guide", style: TextStyle(color: Colors.white)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildObjectiveSection(),
              const Divider(color: Colors.white24, height: 32),
              const Text("Battle Mechanics", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              _buildExpansionHelpItem(
                "Attack", 
                Icons.fireplace, 
                Colors.redAccent, 
                "Hit an enemy to lower their health! The higher your hero's Attack power and the lower the enemy's Defense, the more damage you'll deal."
              ),
              _buildExpansionHelpItem(
                "Defend", 
                Icons.shield, 
                Colors.blueAccent, 
                "Increases 'Taunt' value, making enemies more likely to target this hero. Also grants damage reduction for one turn."
              ),
              _buildHelpSupportItem(),
              const Divider(color: Colors.white24, height: 32),
              _buildHelpItem(
                "Action Order Bar", 
                Icons.view_headline, 
                Colors.yellow, 
                "See who goes next! The hero on the left is acting NOW. Upcoming heroes move from right to left towards the turn arrow."
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("GOT IT", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildObjectiveSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Goal", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 4),
        Text(
          "Knock out all 4 heroes on the enemy team to win! Pick the best moves to beat them.",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        SizedBox(height: 12),
        Text("How to Win", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(
          "You win when every enemy hero runs out of health. If all your heroes get knocked out first, you lose.",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildExpansionHelpItem(String title, IconData icon, Color color, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ExpansionTile(
          iconColor: color,
          collapsedIconColor: color,
          leading: Icon(icon, color: color),
          title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          childrenPadding: const EdgeInsets.all(12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String title, IconData icon, Color color, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildHelpSupportItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ExpansionTile(
          iconColor: Colors.greenAccent,
          collapsedIconColor: Colors.greenAccent,
          leading: const Icon(Icons.auto_awesome, color: Colors.greenAccent),
          title: const Text("Support", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          childrenPadding: const EdgeInsets.all(12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How to apply: Select 'Support' then tap an ally hero to buff them.",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Text(
              "The buff type depends on the ACTOR's highest power stat:",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _buildStatBuff("Intelligence", "Action Advance (Next turn comes sooner)"),
            _buildStatBuff("Strength", "Damage Boost (Next attack deals more dmg)"),
            _buildStatBuff("Speed", "SPD Buff (Higher speed for 2 turns)"),
            _buildStatBuff("Durability", "Shield/DR (Reduced damage for 2 hits)"),
            _buildStatBuff("Power", "Crit Chance (50% more likely to crit)"),
            _buildStatBuff("Combat", "Crit Damage (25% more critical damage)"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBuff(String stat, String effect) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: "• $stat: ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            TextSpan(text: effect, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}




