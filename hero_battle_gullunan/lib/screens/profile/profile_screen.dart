import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _playerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _playerNameController.text = context.read<PlayerProvider>().playerName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Profile')),
      body: Consumer<PlayerProvider>(
        builder: (context, player, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Player Info',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _playerNameController,
                  decoration: InputDecoration(
                    labelText: 'Player Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final name = _playerNameController.text;
                    await player.updatePlayerName(name);
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Player name updated')),
                    );
                  },
                  child: const Text('Update Name'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark Theme'),
                    subtitle: Text(player.isDarkTheme ? 'Enabled' : 'Disabled'),
                    trailing: Switch(
                      value: player.isDarkTheme,
                      onChanged: (_) async {
                        await player.toggleTheme();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Total Wins'),
                    trailing: Text(
                      player.totalWins.toString(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }
}
