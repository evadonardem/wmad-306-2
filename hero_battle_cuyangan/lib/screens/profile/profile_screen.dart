import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header with Hero Avatar
            _buildProfileHeader(),

            const SizedBox(height: 24),

            // Settings Section with Card Layout
            _buildSettingsSection(),

            const SizedBox(height: 24),

            // Battle Stats Section
            _buildBattleStatsSection(),

            const SizedBox(height: 24),

            // About Section
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        return Column(
          children: [
            // Large Hero Avatar Icon with breathing room
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.security, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 32), // Extra breathing room
          ],
        );
      },
    );
  }

  Widget _buildSettingsSection() {
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title
                Text(
                  'Player Settings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Player Name Section
                Row(
                  children: [
                    const Icon(Icons.person, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Player Name',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          if (!_isEditingName) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    player.playerName,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _nameController.text = player.playerName;
                                    setState(() {
                                      _isEditingName = true;
                                    });
                                  },
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Edit Name',
                                ),
                              ],
                            ),
                          ] else ...[
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Player Name',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              autofocus: true,
                              onSubmitted: (value) => _savePlayerName(),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditingName = false;
                                    });
                                  },
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _savePlayerName,
                                  icon: const Icon(Icons.save, size: 16),
                                  label: const Text('Save'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Theme Toggle Section (Exercise 3)
                Row(
                  children: [
                    Icon(
                      player.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  player.isDarkTheme
                                      ? 'Dark Mode'
                                      : 'Light Mode',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Switch(
                                value: player.isDarkTheme,
                                onChanged: (value) {
                                  // Exercise 3: Call PlayerProvider.toggleTheme() to update MaterialApp
                                  player.toggleTheme();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBattleStatsSection() {
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        return Card(
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Battle Stats',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.amber),
                title: const Text('Total Wins'),
                subtitle: const Text('Battles won'),
                trailing: Text(
                  '${player.totalWins}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.trending_up, color: Colors.green),
                title: const Text('Win Rate'),
                subtitle: const Text('Performance metric'),
                trailing: Text(
                  player.totalWins > 0
                      ? '${(player.totalWins / 10 * 100).toInt()}%'
                      : '0%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 8),
          // Footer - smaller and centered
          Center(
            child: Column(
              children: [
                Text(
                  'Hero Battle App',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Build your ultimate hero deck and battle against friends!',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _savePlayerName() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      context.read<PlayerProvider>().updatePlayerName(name);
      setState(() {
        _isEditingName = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Player name updated!')));
    }
  }
}
