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
      appBar: AppBar(title: const Text('Player Profile')),
      body: Consumer<PlayerProvider>(
        builder: (context, player, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Player name',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: player.updatePlayerName,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => player.updatePlayerName(_controller.text),
                child: const Text('Save Name'),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                value: player.isDarkTheme,
                onChanged: (_) => player.toggleTheme(),
                title: const Text('Dark mode'),
              ),
              ListTile(
                title: const Text('Total wins'),
                trailing: Text(player.totalWins.toString()),
              ),
            ],
          );
        },
      ),
    );
  }
}
