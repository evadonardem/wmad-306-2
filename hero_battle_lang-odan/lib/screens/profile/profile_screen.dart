import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/player_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<PlayerProvider>().playerName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<PlayerProvider>(
        builder: (context, player, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Player Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final value = _controller.text.trim();
                await context.read<PlayerProvider>().updatePlayerName(
                      value.isEmpty ? 'Hero' : value,
                    );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Player name saved.')),
                );
              },
              child: const Text('Save Name'),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              value: player.isDarkTheme,
              title: const Text('Dark Theme'),
              onChanged: (_) => context.read<PlayerProvider>().toggleTheme(),
            ),
            ListTile(
              title: const Text('Total Wins'),
              trailing: Text('${player.totalWins}'),
            ),
          ],
        ),
      ),
    );
  }
}
