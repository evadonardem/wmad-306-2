import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<PlayerProvider>(
        builder: (_, player, __) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Avatar + name ────────────────────────────────────────
            _AvatarSection(player: player),
            const SizedBox(height: 28),

            // ── Stats ────────────────────────────────────────────────
            Text('Battle Statistics',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _StatsCard(player: player),
            const SizedBox(height: 28),

            // ── Settings ─────────────────────────────────────────────
            Text('Settings',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Exercise 3 — Theme toggle persisted via SharedPreferences
            Card(
              child: SwitchListTile(
                secondary: Icon(
                  player.isDarkTheme
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                ),
                title: const Text('Dark Mode'),
                subtitle: Text(player.isDarkTheme ? 'Dark theme active' : 'Light theme active'),
                value: player.isDarkTheme,
                // Switches immediately app-wide via Consumer in main.dart
                onChanged: (_) => player.toggleTheme(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar + editable name ────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final PlayerProvider player;
  const _AvatarSection({required this.player});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.primaryContainer,
            boxShadow: [
              BoxShadow(
                  color: cs.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2)
            ],
          ),
          child: Center(
            child: Text(
              player.playerName.isNotEmpty
                  ? player.playerName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: cs.onPrimaryContainer),
            ),
          ),
        )
            .animate()
            .scale(duration: 500.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 300.ms),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              player.playerName,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Edit name',
              onPressed: () => _editName(context, player),
            ),
          ],
        ),
      ],
    );
  }

  void _editName(BuildContext context, PlayerProvider player) {
    final ctrl = TextEditingController(text: player.playerName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Player Name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 20,
          decoration: const InputDecoration(
            labelText: 'Your name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) {
            player.updatePlayerName(v);
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              player.updatePlayerName(ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Stats card ────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final PlayerProvider player;
  const _StatsCard({required this.player});

  @override
  Widget build(BuildContext context) {
    final rate = player.totalBattles == 0
        ? 0.0
        : player.totalWins / player.totalBattles;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                    label: 'Battles',
                    value: '${player.totalBattles}',
                    icon: '⚔️'),
                _StatItem(
                    label: 'Wins',
                    value: '${player.totalWins}',
                    icon: '🏆',
                    color: Colors.greenAccent),
                _StatItem(
                    label: 'Losses',
                    value: '${player.totalLosses}',
                    icon: '💀',
                    color: Colors.redAccent),
              ],
            ),
            if (player.totalBattles > 0) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text('Win Rate  ',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: rate,
                        minHeight: 8,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation(
                            rate >= 0.5 ? Colors.greenAccent : Colors.orangeAccent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(rate * 100).round()}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value, icon;
  final Color? color;
  const _StatItem(
      {required this.label,
      required this.value,
      required this.icon,
      this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
}
