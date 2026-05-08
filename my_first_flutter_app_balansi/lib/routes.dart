import 'package:flutter/material.dart';

import 'features/details/widgets/details_screen.dart';
import 'features/favorites/widgets/favorites_screen.dart';
import 'features/pokedex/widgets/pokedex_screen.dart';

/// Centralised named-route table.
class Routes {
  Routes._();

  static const String home = '/';
  static const String details = '/details';
  static const String favorites = '/favorites';

  static Route<dynamic>? generate(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const PokedexScreen());
      case details:
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => DetailsScreen(pokemonId: id),
        );
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      default:
        return null;
    }
  }
}
