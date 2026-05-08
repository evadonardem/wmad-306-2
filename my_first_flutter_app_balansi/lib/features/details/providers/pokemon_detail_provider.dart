import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/pokemon_detail.dart';
import '../../pokedex/providers/pokedex_list_provider.dart';

/// Fetches the full detail record for a Pokémon by id. Family allows one
/// provider per id with independent loading/error states.
final pokemonDetailProvider =
    FutureProvider.family<PokemonDetail, int>((ref, id) async {
  final service = ref.watch(pokeapiServiceProvider);
  return service.fetchPokemonDetail(id);
});
