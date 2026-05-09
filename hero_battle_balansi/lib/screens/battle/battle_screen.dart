// Visual Duel — VERSUS layout, animated HP bars, log feed, phase banner,
// Change Card swap sheet, Continue Battle replay button.
//
// The BattleProvider auto-saves a BattleRecord to SQLite on completion (Ex 2).

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/_neon.dart';
import '../../widgets/hp_bar.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});
  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  Future<void> _attack() async {
    final battle = context.read<BattleProvider>();
    final player = context.read<PlayerProvider>();
    if (!battle.canAct) return;
    await battle.playerAttack(player);
  }

  Future<void> _openSwapSheet() async {
    final battle = context.read<BattleProvider>();
    final deck = context.read<DeckProvider>();
    if (!battle.canAct) return;

    final active = battle.player;
    final candidates = deck.deck
        .where((h) => active == null || h.id != active.id)
        .toList();

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kSurface,
          content: Text(
            'No bench heroes — add more to your deck.',
            style: TextStyle(color: kNeonMagenta),
          ),
        ),
      );
      return;
    }

    final picked = await showModalBottomSheet<HeroModel>(
      context: context,
      backgroundColor: kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: kNeonCyan, width: 1.4),
      ),
      builder: (ctx) => _SwapSheet(candidates: candidates),
    );
    if (picked != null && mounted) {
      battle.swapHero(picked);
    }
  }

  void _continueBattle(BattleProvider battle, DeckProvider deck) {
    if (deck.deck.isEmpty) return;
    final player = deck.deck.first;
    final ai = deck.deck.length > 1 ? deck.deck.last : player;
    battle.continueBattle(player, ai);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<BattleProvider>(
          builder: (_, b, _) => Text(
            b.player == null ? 'Battle' : 'Round ${b.rounds}',
          ),
        ),
      ),
      body: Consumer<BattleProvider>(
        builder: (context, battle, _) {
          final player = battle.player;
          final ai = battle.ai;
          if (player == null || ai == null) {
            return const Center(
              child: Text(
                'No active battle.',
                style: TextStyle(color: kTextDim),
              ),
            );
          }

          // Custom: heavy hits (>30 dmg) shake the entire scaffold.
          final shakeKey = ValueKey(
            'shake-${battle.rounds}-${battle.lastTarget}-${battle.lastDamage}',
          );

          Widget arena = SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                children: [
                  _PhaseBanner(battle: battle),
                  const SizedBox(height: 10),
                  _Fighter(
                    hero: ai,
                    hp: battle.aiHp,
                    maxHp: battle.aiMaxHp,
                    flipped: true,
                    flashing: battle.lastTarget == 'ai',
                    flashKey: ValueKey('ai-${battle.rounds}-${battle.lastDamage}'),
                    isAttacking: battle.phase == BattlePhase.aiTurn,
                  ),
                  const _VersusBadge(),
                  _Fighter(
                    hero: player,
                    hp: battle.playerHp,
                    maxHp: battle.playerMaxHp,
                    flashing: battle.lastTarget == 'player',
                    flashKey: ValueKey('p-${battle.rounds}-${battle.lastDamage}'),
                    isAttacking: battle.phase == BattlePhase.playerTurn,
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: _BattleLog(log: battle.log)),
                  const SizedBox(height: 10),
                  _ActionBar(
                    battle: battle,
                    onAttack: _attack,
                    onSwap: _openSwapSheet,
                  ),
                ],
              ),
            ),
          );

          // Screen shake on heavy hits.
          if (battle.lastDamage > 30 && battle.rounds > 0 && !battle.isOver) {
            arena = arena
                .animate(key: shakeKey)
                .shake(hz: 6, duration: 320.ms, offset: const Offset(4, 0));
          }

          return Stack(
            children: [
              arena,
              // Result overlay — replaces the old AlertDialog.
              if (battle.phase == BattlePhase.ended)
                _ResultOverlay(
                  battle: battle,
                  onContinue: () =>
                      _continueBattle(battle, context.read<DeckProvider>()),
                  onExit: () => Navigator.pop(context),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Phase banner ────────────────────────────────────────────────────────
class _PhaseBanner extends StatelessWidget {
  final BattleProvider battle;
  const _PhaseBanner({required this.battle});

  Color _accent() {
    switch (battle.phase) {
      case BattlePhase.playerTurn:
        return kNeonCyan;
      case BattlePhase.aiTurn:
        return const Color(0xFFFF3D6E);
      case BattlePhase.ended:
        return battle.playerWon ? kNeonCyan : kNeonMagenta;
      case BattlePhase.waiting:
        return kNeonMagenta;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent, width: 1.4),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.45), blurRadius: 14),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ROUND ${battle.rounds}',
            style: const TextStyle(
              color: kTextDim,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          Text(
            battle.phaseLabel,
            key: ValueKey(battle.phaseLabel + battle.rounds.toString()),
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: 14,
            ),
          )
              .animate(key: ValueKey(battle.phase.name + battle.rounds.toString()))
              .fadeIn(duration: 220.ms)
              .slide(begin: const Offset(0.2, 0)),
        ],
      ),
    );
  }
}

// ── Versus badge ────────────────────────────────────────────────────────
class _VersusBadge extends StatelessWidget {
  const _VersusBadge();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 1.5,
              color: kNeonCyan.withValues(alpha: 0.25),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: kBgDeep,
                border: Border.all(color: kNeonMagenta, width: 1.4),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kNeonMagenta.withValues(alpha: 0.6),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Text(
                'VERSUS',
                style: kNeonTitle.copyWith(
                  fontSize: 18,
                  color: kNeonMagenta,
                  letterSpacing: 4,
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .shimmer(duration: 1800.ms, color: kNeonCyan)
                .scaleXY(end: 1.04, duration: 1800.ms),
          ],
        ),
      );
}

// ── Fighter card (bigger, with attacking accent ring) ───────────────────
class _Fighter extends StatelessWidget {
  final HeroModel hero;
  final int hp;
  final int maxHp;
  final bool flipped;
  final bool flashing;
  final bool isAttacking;
  final Key flashKey;

  const _Fighter({
    required this.hero,
    required this.hp,
    required this.maxHp,
    this.flipped = false,
    required this.flashing,
    required this.flashKey,
    required this.isAttacking,
  });

  @override
  Widget build(BuildContext context) {
    final accent = flipped ? kNeonMagenta : kNeonCyan;

    Widget portrait = Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAttacking ? kNeonCyan : accent,
          width: isAttacking ? 2.4 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAttacking ? kNeonCyan : accent)
                .withValues(alpha: isAttacking ? 0.85 : 0.5),
            blurRadius: isAttacking ? 22 : 14,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: hero.imageUrl,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => const Icon(Icons.bolt, color: kNeonCyan),
      ),
    );

    // Receiving-side flash + shake when this fighter takes damage.
    if (flashing) {
      portrait = portrait
          .animate(key: flashKey)
          .shake(hz: 8, duration: 250.ms)
          .tint(color: kNeonMagenta.withValues(alpha: 0.5), duration: 200.ms);
    }
    // Attacker lunges forward briefly.
    if (isAttacking) {
      portrait = portrait
          .animate(key: ValueKey('atk-${hero.id}-$isAttacking'))
          .moveX(begin: 0, end: flipped ? 0 : 14, duration: 200.ms)
          .then()
          .moveX(begin: 0, end: flipped ? 0 : -14, duration: 200.ms);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          portrait,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accent),
                      ),
                      child: Text(
                        flipped ? 'AI' : 'YOU',
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.flash_on,
                        size: 14, color: accent.withValues(alpha: 0.8)),
                    Text(
                      ' ATK ${hero.attack}',
                      style: const TextStyle(
                        color: kTextDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.shield,
                        size: 14, color: accent.withValues(alpha: 0.8)),
                    Text(
                      ' DEF ${hero.defense}',
                      style: const TextStyle(
                        color: kTextDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hero.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kNeonTitle.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 8),
                HpBar(
                  currentHp: hp,
                  maxHp: maxHp,
                  label: flipped ? 'AI HP' : 'YOUR HP',
                  flipped: flipped,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Battle log ──────────────────────────────────────────────────────────
class _BattleLog extends StatelessWidget {
  final List<String> log;
  const _BattleLog({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: neonBorder(color: kNeonCyan, glow: 4),
      child: ListView.builder(
        reverse: true,
        itemCount: log.length,
        itemBuilder: (_, i) {
          final entry = log[log.length - 1 - i];
          // Newest entry highlights briefly.
          final isLatest = i == 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              entry,
              style: TextStyle(
                color: isLatest ? kNeonCyan : kTextPrimary,
                fontSize: 12,
                fontWeight: isLatest ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Action bar (Attack + Swap) ──────────────────────────────────────────
class _ActionBar extends StatelessWidget {
  final BattleProvider battle;
  final VoidCallback onAttack;
  final VoidCallback onSwap;

  const _ActionBar({
    required this.battle,
    required this.onAttack,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !battle.canAct;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            onPressed: disabled ? null : onAttack,
            icon: const Icon(Icons.bolt),
            label: const Text('ATTACK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kNeonCyan,
              foregroundColor: kBgDeep,
              minimumSize: const Size.fromHeight(54),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: disabled ? null : onSwap,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('SWAP'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: disabled
                    ? kTextDim.withValues(alpha: 0.4)
                    : kNeonMagenta,
                width: 1.6,
              ),
              foregroundColor: disabled ? kTextDim : kNeonMagenta,
              minimumSize: const Size.fromHeight(54),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Swap modal bottom sheet ─────────────────────────────────────────────
class _SwapSheet extends StatelessWidget {
  final List<HeroModel> candidates;
  const _SwapSheet({required this.candidates});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kNeonCyan.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'CHANGE CARD',
              style: kNeonTitle.copyWith(fontSize: 18, color: kNeonCyan),
            ),
            const SizedBox(height: 4),
            const Text(
              'HP percentage carries over to the new hero.',
              style: TextStyle(color: kTextDim, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: candidates.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _SwapRow(hero: candidates[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapRow extends StatelessWidget {
  final HeroModel hero;
  const _SwapRow({required this.hero});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.pop(context, hero),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: neonBorder(glow: 6),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: CachedNetworkImage(
                  imageUrl: hero.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) =>
                      const Icon(Icons.bolt, color: kNeonCyan),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hero.name,
                    style: kNeonTitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'HP ${hero.maxHp}  •  ATK ${hero.attack}  •  DEF ${hero.defense}',
                    style: const TextStyle(color: kTextDim, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.swap_horiz, color: kNeonMagenta),
          ],
        ),
      ),
    );
  }
}

// ── Result overlay (Victory / Defeat + Continue) ────────────────────────
class _ResultOverlay extends StatelessWidget {
  final BattleProvider battle;
  final VoidCallback onContinue;
  final VoidCallback onExit;

  const _ResultOverlay({
    required this.battle,
    required this.onContinue,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final won = battle.playerWon;
    final accent = won ? kNeonCyan : kNeonMagenta;
    final title = won ? 'VICTORY' : 'DEFEAT';
    final emoji = won ? '🏆' : '💀';

    return Positioned.fill(
      child: Container(
        color: kBgDeep.withValues(alpha: 0.85),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.7),
                  blurRadius: 32,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 56),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1.08, 1.08),
                      duration: 900.ms,
                    ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: kNeonTitle.copyWith(
                    fontSize: 36,
                    color: accent,
                    letterSpacing: 6,
                    shadows: [
                      Shadow(
                        color: accent.withValues(alpha: 0.8),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .scale(begin: const Offset(0.7, 0.7))
                    .then()
                    .shimmer(duration: 1100.ms, color: accent),
                const SizedBox(height: 6),
                Text(
                  '${battle.player?.name ?? "?"}  vs  ${battle.ai?.name ?? "?"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kTextPrimary, fontSize: 14),
                ),
                Text(
                  'Survived ${battle.rounds} round${battle.rounds == 1 ? "" : "s"}',
                  style: const TextStyle(color: kTextDim, fontSize: 12),
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.replay),
                  label: const Text('CONTINUE BATTLE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: kBgDeep,
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onExit,
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Exit Battle'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: accent.withValues(alpha: 0.6)),
                    foregroundColor: accent,
                    minimumSize: const Size.fromHeight(46),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 220.ms)
              .scale(
                begin: const Offset(0.85, 0.85),
                duration: 320.ms,
                curve: Curves.easeOutBack,
              ),
        ),
      ),
    );
  }
}
