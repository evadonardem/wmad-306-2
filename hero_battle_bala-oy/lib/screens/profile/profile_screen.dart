import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/player_provider.dart';
import '../../router/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _openDrawerArg = 'openDrawer';
  static const String _fromDrawerArg = 'fromDrawer';

  late final TextEditingController _nameController;
  bool _soundEffectsEnabled = true;
  bool _notificationsEnabled = false;

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

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            final args = ModalRoute.of(context)?.settings.arguments;
            final openedFromDrawer =
                args is Map<String, dynamic> && args[_fromDrawerArg] == true;
            if (openedFromDrawer) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                RouteNames.home,
                (_) => false,
                arguments: <String, dynamic>{_openDrawerArg: true},
              );
              return;
            }

            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
              return;
            }
            navigator.pushReplacementNamed(
              RouteNames.home,
              arguments: <String, dynamic>{_openDrawerArg: true},
            );
          },
        ),
        title: const Text('Player Profile'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF12101D), Color(0xFF1F1D35)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              // Profile Header
              _buildProfileHeader(player, theme),
              const SizedBox(height: 32),

              // Stats Section
              _buildStatsSection(player, theme),
              const SizedBox(height: 32),

              // Settings Section
              _buildSettingsSection(player, theme),
              const SizedBox(height: 24),

              // Name Update Section
              _buildNameUpdateSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(PlayerProvider player, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.15), // Gold accent
            theme.colorScheme.primary.withValues(alpha: 0.12),
            theme.colorScheme.secondary.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with level indicator
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFD700).withValues(alpha: 0.6),
                      theme.colorScheme.primary.withValues(alpha: 0.4),
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              // Level badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.redAccent,
                        Colors.orangeAccent,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '${player.totalWins + 1}', // Level based on wins
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            player.playerName,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.purpleAccent.withValues(alpha: 0.2),
                  Colors.blueAccent.withValues(alpha: 0.2),
                ],
              ),
              border: Border.all(
                color: Colors.purpleAccent.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'Combat Commander',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Achievement badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAchievementBadge(
                icon: Icons.military_tech,
                color: Colors.amber,
                earned: player.totalWins > 0,
              ),
              const SizedBox(width: 12),
              _buildAchievementBadge(
                icon: Icons.local_fire_department,
                color: Colors.redAccent,
                earned: player.totalWins >= 5,
              ),
              const SizedBox(width: 12),
              _buildAchievementBadge(
                icon: Icons.star,
                color: Colors.yellowAccent,
                earned: player.totalWins >= 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(PlayerProvider player, ThemeData theme) {
    final totalBattles = player.totalWins + (player.totalWins ~/ 2); // Assuming some losses
    final winRate = totalBattles > 0 ? (player.totalWins / totalBattles * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Battle Statistics',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildStatRow(
                'Total Wins',
                player.totalWins.toString(),
                Colors.greenAccent,
                Icons.military_tech,
                theme,
              ),
              const SizedBox(height: 20),
              _buildStatRow(
                'Win Rate',
                '$winRate%',
                Colors.blueAccent,
                Icons.trending_up,
                theme,
              ),
              const SizedBox(height: 20),
              _buildStatRow(
                'Battles Played',
                totalBattles.toString(),
                Colors.amberAccent,
                Icons.sports_martial_arts,
                theme,
              ),
              const SizedBox(height: 20),
              _buildStatRow(
                'Current Streak',
                '3', // Placeholder - would need to track this
                Colors.redAccent,
                Icons.local_fire_department,
                theme,
              ),
              const SizedBox(height: 20),
              _buildStatRow(
                'Hero Collection',
                '12', // Placeholder - would need to track this
                Colors.purpleAccent,
                Icons.collections,
                theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge({
    required IconData icon,
    required Color color,
    required bool earned,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: earned
            ? LinearGradient(
                colors: [
                  color.withValues(alpha: 0.8),
                  color.withValues(alpha: 0.4),
                ],
              )
            : LinearGradient(
                colors: [
                  Colors.grey.withValues(alpha: 0.3),
                  Colors.grey.withValues(alpha: 0.1),
                ],
              ),
        border: Border.all(
          color: earned ? color.withValues(alpha: 0.6) : Colors.grey.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        color: earned ? Colors.white : Colors.grey.withValues(alpha: 0.5),
        size: 20,
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color accentColor,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                accentColor.withValues(alpha: 0.3),
                accentColor.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                accentColor.withValues(alpha: 0.2),
                accentColor.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: accentColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(PlayerProvider player, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Game Preferences',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSettingRow(
                  label: 'Theme',
                  subtitle: player.isDarkTheme ? 'Dark Mode' : 'Light Mode',
                  icon: player.isDarkTheme
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  accentColor: Colors.indigoAccent,
                  theme: theme,
                  trailing: Switch(
                    value: player.isDarkTheme,
                    onChanged: (_) =>
                        context.read<PlayerProvider>().toggleTheme(),
                    thumbColor: WidgetStatePropertyAll(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSettingRow(
                  label: 'Sound Effects',
                  subtitle: 'Battle sounds enabled',
                  icon: Icons.volume_up_rounded,
                  accentColor: Colors.greenAccent,
                  theme: theme,
                  trailing: Switch(
                    value: _soundEffectsEnabled,
                    onChanged: (_) {
                      setState(() {
                        _soundEffectsEnabled = !_soundEffectsEnabled;
                      });
                    },
                    thumbColor: WidgetStatePropertyAll(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSettingRow(
                  label: 'Notifications',
                  subtitle: 'Battle reminders',
                  icon: Icons.notifications_rounded,
                  accentColor: Colors.orangeAccent,
                  theme: theme,
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (_) {
                      setState(() {
                        _notificationsEnabled = !_notificationsEnabled;
                      });
                    },
                    thumbColor: WidgetStatePropertyAll(theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required ThemeData theme,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                accentColor.withValues(alpha: 0.3),
                accentColor.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _buildNameUpdateSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Update Profile',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Player Name',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your hero name',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please enter a hero name'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      return;
                    }
                    final messenger = ScaffoldMessenger.of(context);
                    final playerProvider = context.read<PlayerProvider>();
                    await playerProvider.updatePlayerName(name);
                    if (!mounted) {
                      return;
                    }
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text('Hero profile updated successfully!'),
                        backgroundColor: Colors.greenAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'Save Hero Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

