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
    _nameController =
        TextEditingController(text: context.read<PlayerProvider>().playerName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<PlayerProvider>(
        builder: (context, player, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Player name'),
                onSubmitted: player.setPlayerName,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Name'),
                onPressed: () => player.setPlayerName(_nameController.text),
              ),
              SwitchListTile(
                title: const Text('Dark theme'),
                value: player.isDarkTheme,
                onChanged: player.setDarkTheme,
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events),
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
