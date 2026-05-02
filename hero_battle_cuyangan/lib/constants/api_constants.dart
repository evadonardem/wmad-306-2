// API Configuration for SuperHero API
// Get your token from: https://superheroapi.com/

class ApiConstants {
  // 🔑 Replace this with your REAL token
  // Example: 102123456789
  static const String apiToken =
      'a634b9460f43ade39c34dc8f896e5941'; // User's actual token API URL
  static const String baseUrl = 'https://superheroapi.com/api';

  // ✅ Check if token is invalid or still placeholder
  static bool isTokenValid() {
    return apiToken.isNotEmpty &&
        apiToken != 'YOUR_REAL_TOKEN_HERE' &&
        apiToken != '1234567890123456';
  }

  // ✅ Get full base API URL with token included
  static String get baseApiUrl {
    if (!isTokenValid()) {
      throw Exception(
        'Invalid API Token. Please update api_constants.dart with your real token from https://superheroapi.com/',
      );
    }
    return '$baseUrl/$apiToken';
  }

  // 🔍 Build search URL
  static String searchHero(String name) {
    return '$baseApiUrl/search/$name';
  }

  // 🧍 Build hero by ID URL
  static String getHeroById(String id) {
    return '$baseApiUrl/$id';
  }
}
