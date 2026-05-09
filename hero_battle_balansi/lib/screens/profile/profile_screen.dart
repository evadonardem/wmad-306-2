// Exercise 3 — Theme toggle. Also hosts player name + wins counter,
// and quick links to History / Saved Decks.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/player_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/_neon.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: context.read<PlayerProvider>().playerName,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: neonBorder(glow: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Player Name', style: kNeonTitle.copyWith(fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        style: const TextStyle(color: kTextPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Hero',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final name = _nameCtrl.text.trim();
                        if (name.isEmpty) return;
                        await context
                            .read<PlayerProvider>()
                            .updatePlayerName(name);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: kSurface,
                            content: Text(
                              'Name saved',
                              style: TextStyle(color: kNeonCyan),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kNeonCyan,
                        foregroundColor: kBgDeep,
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Narrow Consumer — only the toggle rebuilds on theme change.
          Consumer<PlayerProvider>(
            builder: (context, player, _) => Container(
              decoration: neonBorder(glow: 8),
              child: SwitchListTile(
                title: Text(
                  'Dark Theme (Neon Noir)',
                  style: kNeonTitle.copyWith(fontSize: 14),
                ),
                subtitle: const Text(
                  'Persists across restarts',
                  style: TextStyle(color: kTextDim, fontSize: 12),
                ),
                value: player.isDarkTheme,
                activeThumbColor: kNeonCyan,
                onChanged: (_) => player.toggleTheme(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<PlayerProvider>(
            builder: (context, player, _) => Container(
              padding: const EdgeInsets.all(16),
              decoration: neonBorder(color: kNeonMagenta, glow: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Wins',
                      style: kNeonTitle.copyWith(fontSize: 16)),
                  Text(
                    '${player.totalWins}',
                    style: kNeonTitle.copyWith(
                      fontSize: 24,
                      color: kNeonMagenta,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.history),
            label: const Text('Battle History'),
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.history),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kNeonCyan),
              foregroundColor: kNeonCyan,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.bookmark),
            label: const Text('Saved Decks'),
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.savedDecks),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kNeonMagenta),
              foregroundColor: kNeonMagenta,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}
