// Manual §5.5 — App entry. MultiProvider registers all ChangeNotifier
// providers at the root. Themes implement the Neon Noir aesthetic.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/battle_provider.dart';
import 'providers/deck_provider.dart';
import 'providers/hero_search_provider.dart';
import 'providers/player_provider.dart';
import 'router/app_router.dart';
import 'services/database_service.dart';
import 'widgets/_neon.dart';

void main() {
  // Required before any platform-channel call (path_provider, sqflite, etc.).
  WidgetsFlutterBinding.ensureInitialized();
  // Wires up the correct sqflite backend for the current platform.
  // Native plugin on iOS/Android, FFI on macOS/Linux/Windows.
  DatabaseService.init();
  runApp(const HeroBattleApp());
}

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
      child: Consumer<PlayerProvider>(
        builder: (context, player, _) {
          return MaterialApp(
            title: 'Hero Battle',
            debugShowCheckedModeBanner: false,
            theme: player.isDarkTheme ? _darkTheme() : _lightTheme(),
            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }

  // ── Neon Noir dark theme ────────────────────────────────────────────────
  ThemeData _darkTheme() {
    final base = ThemeData(
      colorSchemeSeed: kNeonCyan,
      brightness: Brightness.dark,
      useMaterial3: true,
    );
    return base.copyWith(
      scaffoldBackgroundColor: kBgDeep,
      colorScheme: base.colorScheme.copyWith(
        primary: kNeonCyan,
        secondary: kNeonMagenta,
        surface: kSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kBgDeep,
        foregroundColor: kNeonCyan,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: kNeonCyan,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
      cardTheme: CardThemeData(
        color: kSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: kNeonCyan, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      iconTheme: const IconThemeData(color: kNeonCyan),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kNeonCyan,
          foregroundColor: kBgDeep,
          elevation: 6,
          shadowColor: kNeonCyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
        labelStyle: const TextStyle(color: kTextDim),
        hintStyle: const TextStyle(color: kTextDim),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kNeonCyan),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kNeonCyan, width: 2),
        ),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: kSurface),
      textTheme: base.textTheme.apply(
        bodyColor: kTextPrimary,
        displayColor: kTextPrimary,
      ),
    );
  }

  // ── Light variant — keeps neon accents on a clean surface ───────────────
  ThemeData _lightTheme() {
    final base = ThemeData(
      colorSchemeSeed: kNeonMagenta,
      brightness: Brightness.light,
      useMaterial3: true,
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF6F4FF),
      colorScheme: base.colorScheme.copyWith(
        primary: kNeonMagenta,
        secondary: kNeonCyan,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: kNeonMagenta,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: kNeonMagenta,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
      iconTheme: const IconThemeData(color: kNeonMagenta),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kNeonMagenta,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
