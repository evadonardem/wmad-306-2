import 'package:flutter/material.dart';
import '../models/hero_model.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/hero_detail_screen.dart';
import '../screens/profile/player_profile_screen.dart';
import '../screens/battle/battle_screen.dart';
import '../screens/battle/battle_history_screen.dart';
import '../screens/deck/deck_screen.dart';

// Route name constants — use these everywhere instead of raw strings
class RouteNames {
  static const splash = '/';
  static const home = '/home';
  static const heroDetail = '/hero-detail';
  static const profile = '/profile';
  static const battle = '/battle';
  static const battleHistory = '/battle-history';
  static const deck = '/deck';
  static const deckBuilder = deck;
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteNames.heroDetail:
        final hero = settings.arguments as HeroModel;
        return MaterialPageRoute(
          builder: (_) => HeroDetailScreen(hero: hero),
        );
      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const PlayerProfileScreen());
      case RouteNames.battle:
        return MaterialPageRoute(builder: (_) => const BattleScreen());
      case RouteNames.battleHistory:
        return MaterialPageRoute(builder: (_) => const BattleHistoryScreen());
      case RouteNames.deck:
        return MaterialPageRoute(builder: (_) => const DeckScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
