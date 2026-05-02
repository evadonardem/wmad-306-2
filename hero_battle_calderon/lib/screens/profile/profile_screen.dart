import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/battle_history_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _isLogoutHovered = false;
  bool _isResetHovered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BattleHistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.person_rounded),
            SizedBox(width: 8),
            Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        elevation: 0,
      ),
      body: Consumer2<PlayerProvider, BattleHistoryProvider>(
        builder: (context, player, historyProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Username'),
                _buildUsernameCard(context, player),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Stats'),
                _buildStatsCard(historyProvider),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Preferences'),
                _buildToggleCard(
                  context,
                  title: 'Theme',
                  subtitle: player.isDarkTheme ? 'Dark Mode' : 'Light Mode',
                  value: player.isDarkTheme,
                  onChanged: (_) => player.toggleTheme(),
                  icon: player.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                ),
                _buildToggleCard(
                  context,
                  title: 'Notifications',
                  subtitle: 'App alerts and updates',
                  value: _notificationsEnabled,
                  onChanged: (val) {
                    setState(() {
                      _notificationsEnabled = val;
                    });
                  },
                  icon: Icons.notifications,
                ),
                const SizedBox(height: 24),
                
                _buildSectionHeader('FAQs'),
                _buildFaqItem('How do I build a deck?', 'Go to the Deck tab and select up to 4 heroes.'),
                _buildFaqItem('How is damage calculated?', 'It is based on Strength, Power, and Combat stats vs the enemy Defense.'),
                _buildFaqItem('What is Action Value?', 'It determines the turn order. Lower value means sooner turns.'),
                _buildFaqItem('How was this App made?', 'A flutter project that is 99.99% bonafide built by AI (0.01% Lrnz. Surprisingly half a day too).'),
                _buildFaqItem('Who is your amazing Teacher?', 'The great sir Dave Medrano.'),
                const SizedBox(height: 32),

                _buildLogoutSection(context),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Account Management'),
        MouseRegion(
          onEnter: (_) => setState(() => _isLogoutHovered = true),
          onExit: (_) => setState(() => _isLogoutHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _showLogoutDialog(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _isLogoutHovered ? Colors.red.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isLogoutHovered ? Colors.red : Colors.red.withValues(alpha: 0.5), 
                  width: 2
                ),
                boxShadow: _isLogoutHovered ? [
                  BoxShadow(color: Colors.red.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 1)
                ] : null,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.red),
                  SizedBox(width: 12),
                  Text(
                    'LOGOUT',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Tooltip(
          message: "Was using this for test purposes",
          child: MouseRegion(
            onEnter: (_) => setState(() => _isResetHovered = true),
            onExit: (_) => setState(() => _isResetHovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _showResetDialog(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _isResetHovered ? Colors.orange.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isResetHovered ? Colors.orange : Colors.orange.withValues(alpha: 0.5), 
                    width: 2
                  ),
                  boxShadow: _isResetHovered ? [
                    BoxShadow(color: Colors.orange.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 1)
                  ] : null,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_forever_rounded, color: Colors.orange),
                    SizedBox(width: 12),
                    Text(
                      'RESET ALL APP DATA',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text("This doesn't work LoL"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Application Data'),
        content: const Text("This will permanently delete all your decks, battle history, and settings. This cannot be undone. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await context.read<PlayerProvider>().resetApp();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('App data has been wiped. Please restart the app for a fully fresh state.'))
                );
              }
            },
            child: const Text('WIPE EVERYTHING'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildUsernameCard(BuildContext context, PlayerProvider player) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(player.playerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => _showEditNameDialog(context, player),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BattleHistoryProvider history) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Matches', history.totalMatches.toString(), Icons.sports_kabaddi, Colors.blue),
            Container(width: 1, height: 40, color: Colors.grey.withAlpha(50)),
            _buildStatItem('Wins', history.totalWins.toString(), Icons.emoji_events, Colors.orange),
            Container(width: 1, height: 40, color: Colors.grey.withAlpha(50)),
            _buildStatItem('Win %', '${history.winRate.toStringAsFixed(1)}%', Icons.show_chart, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildToggleCard(BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, PlayerProvider player) {
    final controller = TextEditingController(text: player.playerName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              player.updatePlayerName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
