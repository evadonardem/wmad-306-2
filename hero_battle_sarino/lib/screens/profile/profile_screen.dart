import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final nameController = TextEditingController(text: player.playerName);

    return Scaffold(
      appBar: AppBar(title: const Text('Player Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Player Name'),
              onSubmitted: (value) => context.read<PlayerProvider>().updatePlayerName(value),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dark Theme'),
                Switch(
                  value: player.isDarkTheme,
                  onChanged: (value) => context.read<PlayerProvider>().toggleTheme(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Total Wins: ${player.totalWins}'),
          ],
        ),
      ),
    );
  }
}