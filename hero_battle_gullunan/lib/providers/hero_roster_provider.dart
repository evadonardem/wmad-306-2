import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';

enum HeroRosterSortType { rarity, name }

class HeroRosterProvider extends ChangeNotifier {
  String _selectedRarityFilter = 'All';
  bool _isSortedAscending = true;
  HeroRosterSortType _sortType = HeroRosterSortType.rarity;
  List<HeroModel> _allHeroes = [];
  List<HeroModel> _filteredAndSortedHeroes = [];

  String get selectedRarityFilter => _selectedRarityFilter;
  bool get isSortedAscending => _isSortedAscending;
  HeroRosterSortType get sortType => _sortType;
  List<HeroModel> get heroes => List.unmodifiable(_filteredAndSortedHeroes);
  String get sortLabel => _sortType == HeroRosterSortType.rarity ? 'Rarity' : 'Name';

  void setAllHeroes(List<HeroModel> heroes) {
    _allHeroes = heroes;
    _applyFiltersAndSort();
  }

  void setRarityFilter(String rarity) {
    _selectedRarityFilter = rarity;
    _applyFiltersAndSort();
  }

  void toggleSortOrder() {
    _isSortedAscending = !_isSortedAscending;
    _applyFiltersAndSort();
  }

  void setSortType(HeroRosterSortType type) {
    _sortType = type;
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    // Apply filter
    List<HeroModel> filtered = _allHeroes;

    if (_selectedRarityFilter != 'All') {
      filtered = _allHeroes.where((hero) {
        return _rarityToString(hero.rarity) == _selectedRarityFilter;
      }).toList();
    }

    // Apply sort
    filtered.sort((a, b) {
      int comparison;
      if (_sortType == HeroRosterSortType.name) {
        comparison = a.name.compareTo(b.name);
      } else {
        comparison = _getRarityValue(a.rarity).compareTo(_getRarityValue(b.rarity));
        if (comparison == 0) {
          comparison = a.name.compareTo(b.name);
        }
      }
      return _isSortedAscending ? comparison : -comparison;
    });

    _filteredAndSortedHeroes = filtered;
    notifyListeners();
  }

  String _rarityToString(HeroRarity rarity) {
    switch (rarity) {
      case HeroRarity.common:
        return 'Common';
      case HeroRarity.rare:
        return 'Rare';
      case HeroRarity.epic:
        return 'Epic';
      case HeroRarity.legendary:
        return 'Legendary';
    }
  }

  int _getRarityValue(HeroRarity rarity) {
    switch (rarity) {
      case HeroRarity.common:
        return 0;
      case HeroRarity.rare:
        return 1;
      case HeroRarity.epic:
        return 2;
      case HeroRarity.legendary:
        return 3;
    }
  }
}
