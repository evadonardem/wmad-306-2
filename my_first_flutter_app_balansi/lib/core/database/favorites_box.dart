import 'package:hive/hive.dart';

import 'hive_boxes.dart';

/// Thin convenience wrapper over the `favorites` Hive box.
class FavoritesBox {
  Box<bool> get _box => Hive.box<bool>(HiveBoxes.favorites);

  Set<int> readAll() =>
      _box.keys.whereType<int>().where((k) => _box.get(k) == true).toSet();

  bool contains(int id) => _box.get(id) == true;

  Future<void> add(int id) => _box.put(id, true);

  Future<void> remove(int id) => _box.delete(id);

  Future<void> toggle(int id) async {
    if (contains(id)) {
      await remove(id);
    } else {
      await add(id);
    }
  }
}
