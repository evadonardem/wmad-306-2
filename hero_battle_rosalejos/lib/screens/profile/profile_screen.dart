import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/stat_row.dart';
import '../../widgets/hero_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('PLAYER PROFILE'),
        ),
        body: Consumer<PlayerProvider>(
          builder: (context, player, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileHeader(player, context),
                const SizedBox(height: 24),
                _buildOptionTile(
                  context,
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () => _showEditProfile(context, player),
                ),
                _buildOptionTile(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () => _showSettings(context, player),
                ),
                _buildOptionTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Support',
                  onTap: () => _showSupport(context),
                ),
                const SizedBox(height: 24),
                _buildStatCard('Total Wins', player.totalWins.toString(), Colors.green),
                const SizedBox(height: 8),
                _buildStatCard('Total Games', player.totalGames.toString(), Colors.blue),
                const SizedBox(height: 24),
                if (player.mostUsedHeroes.isNotEmpty) ...[
                  Text(
                    'MOST USED HERO${player.mostUsedHeroes.length > 1 ? "ES" : ""}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: player.mostUsedHeroes.length,
                    itemBuilder: (context, index) {
                      return HeroCard(hero: player.mostUsedHeroes[index]);
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(PlayerProvider player, BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.person, size: 50),
        ),
        const SizedBox(height: 16),
        Text(
          player.playerName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildOptionTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showEditProfile(BuildContext context, PlayerProvider player) {
    final controller = TextEditingController(text: player.playerName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Player Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              player.updatePlayerName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context, PlayerProvider player) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Settings',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SwitchListTile(
              title: const Text('Change Theme'),
              subtitle: const Text('Switch between light and dark mode'),
              value: player.isDarkTheme,
              onChanged: (value) {
                player.toggleTheme();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Clear User Data',
                  style: TextStyle(color: Colors.red)),
              subtitle: const Text('Reset all wins, games, decks, and settings'),
              onTap: () {
                _confirmClearData(context, player);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearData(BuildContext context, PlayerProvider player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
            'This will reset your name, wins, games, and delete all saved decks. This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await player.clearData();
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared.')),
                );
              }
            },
            child: const Text('CLEAR ALL',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Support & Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hero Battle is a strategic card game where you build decks of your favorite superheroes and battle against AI opponents in a Pokémon-inspired turn-based combat system.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              const Text('Deck Mechanics:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('• Build a deck of up to 5 heroes.\n• Total deck cost must not exceed 15 points.\n• Hero costs are calculated based on their total base stats (1-6).'),
              const SizedBox(height: 16),
              const Text('Game Mechanics:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('• Battles are turn-based. Speed dictates who goes first.\n• HP is calculated as (Durability × 5) + Strength.\n• Three universal moves:\n  - Brutal Strike: Strength vs Durability.\n  - Energy Manifest: Power vs Intelligence.\n  - Precision Assault: Combat vs Speed.'),
              const SizedBox(height: 16),
              const Text('Strategy Tip:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Analyze your opponent! Use moves that target their lowest defensive stat to maximize damage.'),
              const SizedBox(height: 16),
              const Text('For further support, contact: support@herobattle.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE')),
        ],
      ),
    );
  }
}
