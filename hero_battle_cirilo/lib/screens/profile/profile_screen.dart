import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Player name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                player.updatePlayerName(_nameController.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Player name saved.')));
              },
              child: const Text('Save name'),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Dark theme'),
              value: player.isDarkTheme,
              onChanged: (_) => player.toggleTheme(),
            ),
            const SizedBox(height: 16),
            Text('Total wins: ${player.totalWins}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Favorite heroes will help you win more battles.', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
