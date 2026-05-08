import 'package:hive_flutter/hive_flutter.dart';

import '../models/pokemon_summary.dart';

/// Box names + bootstrap helpers for Hive persistence.
class HiveBoxes {
  HiveBoxes._();

  /// Cached basic Pokémon list (key = id, value = PokemonSummary).
  static const String pokedexSummaries = 'pokedex_summaries';

  /// Favorited Pokémon (key = id, value = true).
  static const String favorites = 'favorites';

  /// Initializes Hive, registers adapters, and opens every box used by the app.
  /// Safe to call once at app startup, before runApp.
  static Future<void> bootstrap() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(PokemonSummaryAdapter().typeId)) {
      Hive.registerAdapter(PokemonSummaryAdapter());
    }

    await Future.wait([
      Hive.openBox<PokemonSummary>(pokedexSummaries),
      Hive.openBox<bool>(favorites),
    ]);
  }
}
