import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/battle_provider.dart';
import 'providers/deck_provider.dart';
import 'providers/hero_search_provider.dart';
import 'providers/player_provider.dart';
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

  ThemeData _darkTheme() => ThemeData(
    colorSchemeSeed: const Color(0xFF7B2FBE),
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF0F0D16),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
        color: Colors.white,
      ),
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Colors.white70,
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1A171F),
      foregroundColor: Colors.white,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: const Color(0xFF1A171F),
      surfaceTintColor: Colors.transparent,
      indicatorColor: const Color(0xFF7B2FBE).withValues(alpha: 0.8),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          );
        }
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1F1C2A),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      surfaceTintColor: Colors.white.withValues(alpha: 0.05),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF7B2FBE),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF7B2FBE),
        side: const BorderSide(
          color: Color(0xFF7B2FBE),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1F1C2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha:0.1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha:0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF7B2FBE),
          width: 2,
        ),
      ),
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha:0.5),
        fontSize: 14,
      ),
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha:0.7),
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIconColor: Colors.white.withValues(alpha:0.6),
      suffixIconColor: Colors.white.withValues(alpha:0.6),
    ),
  );

  ThemeData _lightTheme() => ThemeData(
    colorSchemeSeed: const Color(0xFF7B2FBE),
    brightness: Brightness.light,
    useMaterial3: true,
  );
}

