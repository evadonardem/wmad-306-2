import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/api/pokeapi_service.dart';
import '../../../core/database/hive_boxes.dart';
import '../../../core/models/pokemon_summary.dart';

/// Single instance of the API service used across providers.
final pokeapiServiceProvider = Provider<PokeapiService>((ref) => PokeapiService());

/// Loads the full Gen 1–6 list. On first launch hits the network and caches
/// to Hive; on subsequent launches returns the cached list immediately and
/// kicks off a background refresh that updates the box on success.
final pokedexListProvider =
    FutureProvider<List<PokemonSummary>>((ref) async {
  final box = Hive.box<PokemonSummary>(HiveBoxes.pokedexSummaries);
  final service = ref.watch(pokeapiServiceProvider);

  // Cached path — return immediately, refresh silently in the background.
  if (box.isNotEmpty) {
    final cached = box.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    // Fire-and-forget refresh; ignore failures so offline use still works.
    // ignore: discarded_futures
    _refreshCache(service, box);
    return cached;
  }

  final list = await service.fetchPokemonList();
  await _writeAll(box, list);
  return list;
});

Future<void> _refreshCache(
  PokeapiService service,
  Box<PokemonSummary> box,
) async {
  try {
    final fresh = await service.fetchPokemonList();
    if (fresh.isNotEmpty) await _writeAll(box, fresh);
  } catch (_) {
    // Background refresh failures are silent on purpose.
  }
}

Future<void> _writeAll(
  Box<PokemonSummary> box,
  List<PokemonSummary> list,
) async {
  await box.clear();
  await box.putAll({for (final p in list) p.id: p});
}
