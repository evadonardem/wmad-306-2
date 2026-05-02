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
    final playerName = context.read<PlayerProvider>().playerName;
    _nameController = TextEditingController(text: playerName);
  }

  Future<void> _savePlayerName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a player name')),
        );
      }
      return;
    }
    
    try {
      final player = context.read<PlayerProvider>();
      await player.updatePlayerName(newName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Player name updated to "$newName"!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<PlayerProvider>(
        builder: (context, player, _) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Profile Avatar
            Center(
              child: CircleAvatar(
                radius: 50,
                child: Text(
                  player.playerName.isNotEmpty ? player.playerName[0].toUpperCase() : 'P',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Player Name
            const Text(
              'Player Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Enter player name',
              ),
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _savePlayerName();
              },
              child: const Text('Save Name'),
            ),
            const SizedBox(height: 24),

            // Battle Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Battle Statistics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Wins:', style: TextStyle(fontSize: 16)),
                        Text('${player.totalWins}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Theme Toggle
            const Text(
              'Display',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(player.isDarkTheme ? Icons.dark_mode : Icons.light_mode),
                title: Text(player.isDarkTheme ? 'Dark Mode' : 'Light Mode'),
                trailing: Switch(
                  value: player.isDarkTheme,
                  onChanged: (_) => player.toggleTheme(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

