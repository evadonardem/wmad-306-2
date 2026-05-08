import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/pokemon_summary.dart';
import 'pokedex_list_provider.dart';

/// Current text in the search bar.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Pokédex list filtered by the active search query (case-insensitive,
/// matches name prefix or padded id).
final filteredPokedexProvider =
    Provider<AsyncValue<List<PokemonSummary>>>((ref) {
  final list = ref.watch(pokedexListProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return list.whenData((all) {
    if (query.isEmpty) return all;
    return all.where((p) {
      final idStr = p.id.toString();
      return p.name.toLowerCase().contains(query) || idStr.contains(query);
    }).toList();
  });
});
