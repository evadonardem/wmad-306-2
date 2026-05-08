import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/favorites_box.dart';

/// Singleton wrapper around the favorites Hive box.
final favoritesBoxProvider = Provider<FavoritesBox>((ref) => FavoritesBox());

/// Set of favorited Pokémon IDs, persisted across app launches.
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier(ref.watch(favoritesBoxProvider));
});

class FavoritesNotifier extends StateNotifier<Set<int>> {
  FavoritesNotifier(this._box) : super(_box.readAll());

  final FavoritesBox _box;

  Future<void> toggle(int id) async {
    await _box.toggle(id);
    state = _box.readAll();
  }

  bool contains(int id) => state.contains(id);
}
