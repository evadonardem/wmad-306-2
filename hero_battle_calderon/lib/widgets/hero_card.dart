import 'package:flutter/material.dart';
import '../models/hero_model.dart';
import 'stat_row.dart';
import 'hero_image.dart';

class HeroCard extends StatelessWidget {
  final HeroModel hero;

  const HeroCard({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showHeroDetails(context),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            HeroImage(
              urls: [hero.imageUrl, hero.akababImageUrl],
              heroId: hero.id,
              heroName: hero.name,
              searchTerms: hero.aliases,
              fit: BoxFit.cover,
              loading: const Center(child: CircularProgressIndicator()),
              error: const Icon(Icons.error),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                  ),
                ),
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  hero.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHeroDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // --- Hero Header ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 150,
                        height: 200,
                        child: HeroImage(
                          urls: [hero.imageUrl, hero.akababImageUrl],
                          heroId: hero.id,
                          heroName: hero.name,
                          searchTerms: hero.aliases,
                          fit: BoxFit.cover,
                          loading: const Center(child: CircularProgressIndicator()),
                          error: const Icon(Icons.error, size: 50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(hero.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    Text(hero.fullName, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey)),

                    // --- Power Stats Section ---
                    ExpansionTile(
                      leading: const Icon(Icons.bar_chart, color: Colors.blue),
                      initiallyExpanded: true,
                      title: const Text('Power Stats', style: TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            children: [
                              StatRow(
                                label: 'Intelligence',
                                value: hero.powerStats.intelligence,
                                color: Colors.blue,
                                icon: Icons.psychology,
                              ),
                              StatRow(
                                label: 'Strength',
                                value: hero.powerStats.strength,
                                color: Colors.red,
                                icon: Icons.fitness_center,
                              ),
                              StatRow(
                                label: 'Speed',
                                value: hero.powerStats.speed,
                                color: Colors.green,
                                icon: Icons.speed,
                              ),
                              StatRow(
                                label: 'Durability',
                                value: hero.powerStats.durability,
                                color: Colors.orange,
                                icon: Icons.shield,
                              ),
                              StatRow(
                                label: 'Power',
                                value: hero.powerStats.power,
                                color: Colors.purple,
                                icon: Icons.bolt,
                              ),
                              StatRow(
                                label: 'Combat',
                                value: hero.powerStats.combat,
                                color: Colors.brown,
                                icon: Icons.sports_martial_arts,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // --- Biography Section ---
                    ExpansionTile(
                      leading: const Icon(Icons.book, color: Colors.teal),
                      title: const Text('Biography', style: TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        _infoTile('Place of Birth', hero.placeOfBirth),
                        _infoTile('First Appearance', hero.firstAppearance),
                        _infoTile('Publisher', hero.publisher),
                        _infoTile('Alignment', hero.alignment.toUpperCase()),
                        if (hero.aliases.isNotEmpty)
                          _infoTile('Aliases', hero.aliases.join(', ')),
                      ],
                    ),

                    // --- Appearance Section ---
                    ExpansionTile(
                      leading: const Icon(Icons.person, color: Colors.orange),
                      title: const Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        _infoTile('Gender', hero.gender),
                        _infoTile('Race', hero.race),
                        _infoTile('Height', hero.height),
                        _infoTile('Weight', hero.weight),
                        _infoTile('Eye Color', hero.eyeColor),
                        _infoTile('Hair Color', hero.hairColor),
                      ],
                    ),

                    // --- Connections Section ---
                    ExpansionTile(
                      leading: const Icon(Icons.group, color: Colors.indigo),
                      title: const Text('Connections', style: TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(hero.groupAffiliation, style: const TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoTile(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(value, style: const TextStyle(fontSize: 14)),
      dense: true,
    );
  }
}
