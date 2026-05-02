import '../services/superhero_api_service.dart';

class ApiTest {
  static Future<void> testApi() async {
    final apiService = SuperheroApiService();
    
    try {
      print('Testing Acabab Superhero API...');
      
      // Test fetching a single hero
      print('\n--- Testing fetchHero(1) ---');
      final hero = await apiService.fetchHero(1);
      print('Hero: ${hero.name}');
      print('Publisher: ${hero.publisher}');
      print('Alignment: ${hero.alignment}');
      print('PowerStats: Intelligence=${hero.powerStats.intelligence}, Strength=${hero.powerStats.strength}');
      print('Image URL: ${hero.imageUrl}');
      
      // Test fetching random heroes
      print('\n--- Testing fetchRandomHeroes(count=3) ---');
      final randomHeroes = await apiService.fetchRandomHeroes(count: 3);
      for (final h in randomHeroes) {
        print('- ${h.name} (${h.publisher})');
      }
      
      // Test search functionality
      print('\n--- Testing searchHeroes("batman") ---');
      final searchResults = await apiService.searchHeroes('batman');
      for (final h in searchResults.take(3)) {
        print('- ${h.name} (${h.publisher})');
      }
      
      // Test publisher filtering
      print('\n--- Testing fetchHeroesByPublisher("Marvel Comics") ---');
      final marvelHeroes = await apiService.fetchHeroesByPublisher('Marvel Comics');
      print('Found ${marvelHeroes.length} Marvel heroes');
      for (final h in marvelHeroes.take(3)) {
        print('- ${h.name}');
      }
      
      print('\nAPI Test completed successfully!');
      
    } catch (e) {
      print('API Test failed: $e');
    }
  }
}
