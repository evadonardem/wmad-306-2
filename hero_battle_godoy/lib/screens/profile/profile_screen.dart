import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
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
          _nameController.text = player.playerName;
          return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Player Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your name',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => player.updatePlayerName(_nameController.text),
            child: const Text('Save Name'),
          ),
          const SizedBox(height: 32),
          Text('Total Wins: ${player.totalWins}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 32),
          SwitchListTile(
            title: const Text('Dark Theme'),
            value: player.isDarkTheme,
            onChanged: (_) => player.toggleTheme(),
          ),
        ],
      );
        },
      ),
    );
  }
}
