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
    _nameController = TextEditingController(
      text: context.read<PlayerProvider>().playerName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await context.read<PlayerProvider>().updatePlayerName(name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Player name saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Player Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saveName(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter player name',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saveName,
              child: const Text('Save Name'),
            ),
            const SizedBox(height: 24),
            Consumer<PlayerProvider>(
              builder: (context, player, _) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark Mode'),
                  subtitle: Text(player.isDarkTheme ? 'Enabled' : 'Disabled'),
                  value: player.isDarkTheme,
                  onChanged: (_) => player.toggleTheme(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
