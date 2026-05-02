import '../models/hero_model.dart';

class MockHeroService {
  static final List<HeroModel> mockHeroes = [
    HeroModel(
      id: '149',
      name: 'Captain America',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/149-captain-america.jpg',
      powerStats: const PowerStats(
        intelligence: 69,
        strength: 79,
        speed: 38,
        durability: 65,
        power: 61,
        combat: 100,
      ),
      publisher: 'Marvel Comics',
      alignment: 'good',
      fullName: 'Steve Rogers',
    ),
    HeroModel(
      id: '69',
      name: 'Batman',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/69-batman.jpg',
      powerStats: const PowerStats(
        intelligence: 100,
        strength: 26,
        speed: 27,
        durability: 50,
        power: 47,
        combat: 100,
      ),
      publisher: 'DC Comics',
      alignment: 'good',
      fullName: 'Bruce Wayne',
    ),
    HeroModel(
      id: '332',
      name: 'Hulk',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/332-hulk.jpg',
      powerStats: const PowerStats(
        intelligence: 54,
        strength: 100,
        speed: 60,
        durability: 100,
        power: 100,
        combat: 70,
      ),
      publisher: 'Marvel Comics',
      alignment: 'good',
      fullName: 'Bruce Banner',
    ),
    HeroModel(
      id: '644',
      name: 'Superman',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/644-superman.jpg',
      powerStats: const PowerStats(
        intelligence: 94,
        strength: 100,
        speed: 100,
        durability: 100,
        power: 100,
        combat: 64,
      ),
      publisher: 'DC Comics',
      alignment: 'good',
      fullName: 'Clark Kent',
    ),
    HeroModel(
      id: '346',
      name: 'Iron Man',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/346-iron-man.jpg',
      powerStats: const PowerStats(
        intelligence: 100,
        strength: 85,
        speed: 58,
        durability: 85,
        power: 100,
        combat: 64,
      ),
      publisher: 'Marvel Comics',
      alignment: 'good',
      fullName: 'Tony Stark',
    ),
    HeroModel(
      id: '620',
      name: 'Spider-Man',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/620-spider-man.jpg',
      powerStats: const PowerStats(
        intelligence: 90,
        strength: 55,
        speed: 67,
        durability: 75,
        power: 74,
        combat: 78,
      ),
      publisher: 'Marvel Comics',
      alignment: 'good',
      fullName: 'Peter Parker',
    ),
    HeroModel(
      id: '720',
      name: 'Wonder Woman',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/720-wonder-woman.jpg',
      powerStats: const PowerStats(
        intelligence: 88,
        strength: 100,
        speed: 61,
        durability: 100,
        power: 100,
        combat: 100,
      ),
      publisher: 'DC Comics',
      alignment: 'good',
      fullName: 'Diana Prince',
    ),
    HeroModel(
      id: '263',
      name: 'Flash',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/263-flash.jpg',
      powerStats: const PowerStats(
        intelligence: 90,
        strength: 16,
        speed: 100,
        durability: 42,
        power: 42,
        combat: 64,
      ),
      publisher: 'DC Comics',
      alignment: 'good',
      fullName: 'Barry Allen',
    ),
    HeroModel(
      id: '38',
      name: 'Aquaman',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/38-aquaman.jpg',
      powerStats: const PowerStats(
        intelligence: 88,
        strength: 80,
        speed: 35,
        durability: 65,
        power: 100,
        combat: 100,
      ),
      publisher: 'DC Comics',
      alignment: 'good',
      fullName: 'Arthur Curry',
    ),
    HeroModel(
      id: '430',
      name: 'Green Lantern',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/430-green-lantern.jpg',
      powerStats: const PowerStats(
        intelligence: 100,
        strength: 100,
        speed: 97,
        durability: 100,
        power: 100,
        combat: 85,
      ),
      publisher: 'DC Comics',
      alignment: 'good',
      fullName: 'Hal Jordan',
    ),
    HeroModel(
      id: '659',
      name: 'Thor',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/659-thor.jpg',
      powerStats: const PowerStats(
        intelligence: 69,
        strength: 100,
        speed: 80,
        durability: 100,
        power: 100,
        combat: 100,
      ),
      publisher: 'Marvel Comics',
      alignment: 'good',
      fullName: 'Thor Odinson',
    ),
    HeroModel(
      id: '262',
      name: 'Black Widow',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/262-black-widow.jpg',
      powerStats: const PowerStats(
        intelligence: 88,
        strength: 40,
        speed: 50,
        durability: 65,
        power: 55,
        combat: 85,
      ),
      publisher: 'Marvel Comics',
      alignment: 'good',
      fullName: 'Natasha Romanoff',
    ),
    HeroModel(
      id: '655',
      name: 'Thanos',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/655-thanos.jpg',
      powerStats: const PowerStats(
        intelligence: 100,
        strength: 100,
        speed: 80,
        durability: 100,
        power: 100,
        combat: 100,
      ),
      publisher: 'Marvel Comics',
      alignment: 'bad',
      fullName: 'Thanos',
    ),
    HeroModel(
      id: '370',
      name: 'Joker',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/370-joker.jpg',
      powerStats: const PowerStats(
        intelligence: 100,
        strength: 10,
        speed: 12,
        durability: 45,
        power: 35,
        combat: 70,
      ),
      publisher: 'DC Comics',
      alignment: 'bad',
      fullName: 'Jack Napier',
    ),
  ];

  static Future<List<HeroModel>> getRandomHeroes({int count = 20}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final shuffled = List<HeroModel>.from(mockHeroes)..shuffle();
    return shuffled.take(count).toList();
  }

  static Future<HeroModel> getHero(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockHeroes.firstWhere((h) => h.id == id.toString());
    } catch (e) {
      // Return a random hero if specific ID isn't found
      final shuffled = List<HeroModel>.from(mockHeroes)..shuffle();
      return shuffled.first;
    }
  }

  static Future<List<HeroModel>> searchHeroes(String name) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockHeroes
        .where((h) => h.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }
}
