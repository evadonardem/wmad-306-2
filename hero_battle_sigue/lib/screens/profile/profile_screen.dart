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
    return Scaffold(
      appBar: AppBar(title: const Text('Player Profile')),
      body: Consumer<PlayerProvider>(
        builder: (context, player, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
              const SizedBox(height: 20),
              Text('Player Name', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      player.updatePlayerName(_nameController.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name updated!')),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              // Exercise 3 — Theme Toggle
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle app theme'),
                trailing: Consumer<PlayerProvider>(
                  builder: (context, p, _) => Switch(
                    value: p.isDarkTheme,
                    onChanged: (_) => p.toggleTheme(),
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text('Total Wins: ${player.totalWins}',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}