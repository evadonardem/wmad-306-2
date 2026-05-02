import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/player_provider.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final player = context.read<PlayerProvider>();
    _nameController = TextEditingController(text: player.playerName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Player name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark theme'),
                    value: player.isDarkTheme,
                    onChanged: (value) async {
                      await context.read<PlayerProvider>().setTheme(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: player.isLoading
                        ? null
                        : () async {
                            await context.read<PlayerProvider>().updatePlayerName(
                                  _nameController.text,
                                );
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  player.errorMessage ?? 'Profile saved.',
                                ),
                              ),
                            );
                          },
                    child: const Text('Save Profile'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Player Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text('Name: ${player.playerName}'),
                  Text('Title: ${player.playerTitle}'),
                  Text('Wins: ${player.totalWins}'),
                  Text('Losses: ${player.totalLosses}'),
                  Text('Battles: ${player.totalBattles}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
