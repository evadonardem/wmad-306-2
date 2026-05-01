import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/services/prefs_service.dart';

class SearchService {
  final PrefsService _prefsService = PrefsService();

  // Enhanced search that includes sub-breeds
  List<Breed> searchBreeds(List<Breed> breeds, String query) {
    if (query.trim().isEmpty) return breeds;

    final lowercaseQuery = query.toLowerCase();
    
    return breeds.where((breed) {
      // Check breed name
      if (breed.name.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }
      
      // Check sub-breed names
      if (breed.subBreeds.any((sub) => sub.toLowerCase().contains(lowercaseQuery))) {
        return true;
      }
      
      return false;
    }).toList();
  }

  // Filter breeds with sub-breeds
  List<Breed> filterBreedsWithSubBreeds(List<Breed> breeds) {
    return breeds.where((breed) => breed.subBreeds.isNotEmpty).toList();
  }

  // Filter breeds without sub-breeds
  List<Breed> filterBreedsWithoutSubBreeds(List<Breed> breeds) {
    return breeds.where((breed) => breed.subBreeds.isEmpty).toList();
  }

  // Filter by favorites status
  Future<List<Breed>> filterByFavorites(List<Breed> breeds) async {
    final favorites = await _prefsService.loadFavorites();
    return breeds.where((breed) => 
      favorites.any((fav) => fav.breedName == breed.name)
    ).toList();
  }

  // Sort breeds A-Z
  List<Breed> sortBreedsAZ(List<Breed> breeds) {
    return breeds..sort((a, b) => a.name.compareTo(b.name));
  }

  // Sort breeds Z-A
  List<Breed> sortBreedsZA(List<Breed> breeds) {
    return breeds..sort((a, b) => b.name.compareTo(a.name));
  }

  // Sort by sub-breed count (most first)
  List<Breed> sortBreedsBySubBreedCount(List<Breed> breeds) {
    return breeds..sort((a, b) => b.subBreeds.length.compareTo(a.subBreeds.length));
  }

  // Get search suggestions based on query
  List<String> getSearchSuggestions(List<Breed> breeds, String query) {
    if (query.trim().isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    final suggestions = <String>{};
    
    for (final breed in breeds) {
      // Add breed name if it matches
      if (breed.name.toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(breed.name);
      }
      
      // Add sub-breed names if they match
      for (final sub in breed.subBreeds) {
        if (sub.toLowerCase().contains(lowercaseQuery)) {
          suggestions.add('$sub ${breed.name}');
        }
      }
    }
    
    return suggestions.take(5).toList(); // Limit to 5 suggestions
  }

  // Get search result count
  int getSearchResultCount(List<Breed> breeds, String query) {
    return searchBreeds(breeds, query).length;
  }
}