import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/deck_provider.dart';
import 'providers/battle_provider.dart';
import 'providers/player_provider.dart';
import 'providers/hero_search_provider.dart';
import 'router/app_router.dart';

void main() => runApp(const HeroBattleApp());

class HeroBattleApp extends StatelessWidget {
  const HeroBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => DeckProvider()),
        ChangeNotifierProvider(create: (_) => BattleProvider()),
        ChangeNotifierProvider(create: (_) => HeroSearchProvider()),
      ],
      // Consumer<PlayerProvider> drives theme switching without rebuilding whole app
      child: Consumer<PlayerProvider>(
        builder: (_, player, __) => MaterialApp(
          title: 'Hero Battle',
          debugShowCheckedModeBanner: false,
          theme: player.isDarkTheme ? _darkTheme() : _lightTheme(),
          initialRoute: RouteNames.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }

  // ── Themes ──────────────────────────────────────────────────────────────

  static ThemeData _darkTheme() => ThemeData(
        colorSchemeSeed: const Color(0xFF7B2FBE),
        brightness: Brightness.dark,
        useMaterial3: true,
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 6,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  static ThemeData _lightTheme() => ThemeData(
        colorSchemeSeed: const Color(0xFF7B2FBE),
        brightness: Brightness.light,
        useMaterial3: true,
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}