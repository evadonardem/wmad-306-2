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
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFFE8D6AA) : const Color(0xFF8E6A2A);
    final pageGradientColors = isDark
        ? const <Color>[Color(0xFF0E1120), Color(0xFF11162A), Color(0xFF0B1020)]
        : <Color>[
            scheme.surface,
            scheme.surfaceContainerLowest,
            scheme.surfaceBright,
          ];
    final cardGradientStart = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.035);
    final cardGradientEnd = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.black.withValues(alpha: 0.018);
    final cardStroke = accent.withValues(alpha: isDark ? 0.18 : 0.26);
    final bannerStroke = accent.withValues(alpha: isDark ? 0.24 : 0.34);
    final subTextColor = isDark
        ? Colors.white.withValues(alpha: 0.75)
        : scheme.onSurface.withValues(alpha: 0.72);

    final bannerGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const <Color>[Color(0xFF171A2A), Color(0xFF121729), Color(0xFF1E2740)]
          : <Color>[
              scheme.surfaceContainer,
              scheme.surface,
              scheme.surfaceContainerHigh,
            ],
    );

    Widget sectionCard({required Widget child}) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[cardGradientStart, cardGradientEnd],
          ),
          border: Border.all(
            color: cardStroke,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );
    }

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: pageGradientColors,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
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
                  const SizedBox(width: 6),
                  Text(
                    'Player Profile',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: bannerGradient,
                  border: Border.all(
                    color: bannerStroke,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFFF4E1B7), Color(0xFFD9A957)],
                        ),
                        border: Border.all(
                          color: (isDark
                                  ? Colors.white
                                  : scheme.onSurface)
                              .withValues(alpha: isDark ? 0.38 : 0.18),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: Color(0xFF211A0F),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            player.playerName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Command Center Profile',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: accent.withValues(alpha: isDark ? 0.16 : 0.12),
                        border: Border.all(
                          color: accent.withValues(alpha: isDark ? 0.52 : 0.44),
                        ),
                      ),
                      child: Text(
                        'Wins ${player.totalWins}',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Identity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Player name',
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.03),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: (isDark
                                    ? Colors.white
                                    : scheme.onSurface)
                                .withValues(alpha: 0.18),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: (isDark
                                    ? Colors.white
                                    : scheme.onSurface)
                                .withValues(alpha: 0.18),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: accent.withValues(alpha: 0.95),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () async {
                          final name = _nameController.text.trim();
                          if (name.isEmpty) {
                            return;
                          }
                          final messenger = ScaffoldMessenger.of(context);
                          final playerProvider = context.read<PlayerProvider>();
                          await playerProvider.updatePlayerName(name);
                          if (!mounted) {
                            return;
                          }
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Profile saved')),
                          );
                        },
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save Name'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Preferences',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: player.isDarkTheme,
                      onChanged: (_) => context.read<PlayerProvider>().toggleTheme(),
                      title: const Text('Dark theme'),
                      subtitle: const Text('Switch between dark and light appearance'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              sectionCard(
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: isDark ? 0.14 : 0.12),
                        border: Border.all(
                          color: accent.withValues(alpha: isDark ? 0.46 : 0.4),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Total Wins',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: subTextColor,
                            ),
                          ),
                          Text(
                            '${player.totalWins}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
