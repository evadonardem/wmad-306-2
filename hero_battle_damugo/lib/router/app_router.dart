import 'package:flutter/material.dart';

import '../models/hero_model.dart';
import '../screens/battle/battle_screen.dart';
import '../screens/deck_builder/deck_builder_screen.dart';
import '../screens/hero_detail/hero_detail_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/saved_decks/saved_decks_screen.dart';
import '../screens/splash/splash_screen.dart';

class RouteNames {
  static const String splash = '/';
  static const String home = '/home';
  static const String heroDetail = '/hero';
  static const String deckBuilder = '/deck';
  static const String battle = '/battle';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String savedDecks = '/saved-decks';
}

class AppRouter {
  static MaterialPageRoute _route(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    return MaterialPageRoute(settings: settings, builder: builder);
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _route(settings, (_) => const SplashScreen());
      case RouteNames.home:
        return _route(settings, (_) => const HomeScreen());
      case RouteNames.heroDetail:
        final args = settings.arguments;
        if (args is HeroModel) {
          return _route(settings, (_) => HeroDetailScreen(hero: args));
        }

        if (args is Map<String, dynamic>) {
          final hero = args['hero'] as HeroModel;
          final alreadyInDeck = args['alreadyInDeck'] as bool? ?? false;
          return _route(
            settings,
            (_) => HeroDetailScreen(
              hero: hero,
              alreadyInDeckFromSource: alreadyInDeck,
            ),
          );
        }

        return _route(settings, (_) => const HomeScreen());
      case RouteNames.deckBuilder:
        return _route(settings, (_) => const DeckBuilderScreen());
      case RouteNames.battle:
        return _route(settings, (_) => const BattleScreen());
      case RouteNames.history:
        return _route(settings, (_) => const HistoryScreen());
      case RouteNames.profile:
        return _route(settings, (_) => const ProfileScreen());
      case RouteNames.savedDecks:
        return _route(settings, (_) => const SavedDecksScreen());
      default:
        return _route(settings, (_) => const HomeScreen());
    }
  }
}
