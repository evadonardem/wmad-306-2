import 'package:flutter/material.dart';

import '../models/hero_model.dart';

// Screens
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/hero_detail/hero_detail_screen.dart';
import '../screens/deck_builder/deck_builder_screen.dart';
import '../screens/battle/battle_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/saved_decks/saved_decks_screen.dart';
import '../screens/main_shell/main_shell_screen.dart';

// 🟣 ROUTE NAMES (USE THESE EVERYWHERE)
class RouteNames {
  static const splash = '/';
  static const mainShell = '/main';
  static const home = '/home';
  static const heroDetail = '/hero';
  static const deckBuilder = '/deck';
  static const savedDecks = '/saved-decks';
  static const battle = '/battle';
  static const history = '/history';
  static const profile = '/profile';
}

// 🟣 APP ROUTER
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

      // 🟣 SPLASH
      case RouteNames.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      // 🟣 HOME
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      // 🟣 MAIN SHELL (Bottom Navigation)
      case RouteNames.mainShell:
        return MaterialPageRoute(
          builder: (_) => const MainShellScreen(),
        );
      case RouteNames.heroDetail:
        final hero = settings.arguments as HeroModel;
        return MaterialPageRoute(
          builder: (_) => HeroDetailScreen(hero: hero),
        );

      // 🟣 DECK BUILDER
      case RouteNames.deckBuilder:
        return MaterialPageRoute(
          builder: (_) => const DeckBuilderScreen(),
        );

      // 🟣 SAVED DECKS
      case RouteNames.savedDecks:
        return MaterialPageRoute(
          builder: (_) => const SavedDecksScreen(),
        );

      // 🟣 BATTLE (Card-based)
      case RouteNames.battle:
        final args = settings.arguments as Map<String, dynamic>;

        final playerDeck = args['playerDeck'] as List<HeroModel>;
        final aiDeck = args['aiDeck'] as List<HeroModel>;

        return MaterialPageRoute(
          builder: (_) => BattleScreen(
            playerDeck: playerDeck,
            aiDeck: aiDeck,
          ),
        );

      // 🟣 HISTORY
      case RouteNames.history:
        return MaterialPageRoute(
          builder: (_) => const HistoryScreen(),
        );

      // 🟣 PROFILE
      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      // 🟣 DEFAULT FALLBACK
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }
}