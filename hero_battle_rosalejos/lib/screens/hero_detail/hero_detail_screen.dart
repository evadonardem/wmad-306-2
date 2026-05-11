import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/hero_model.dart';
import '../../widgets/stat_row.dart';

class HeroDetailScreen extends StatelessWidget {
  final HeroModel hero;
  const HeroDetailScreen({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(hero.name),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 16.0),
              child: Text(
                'COST: ${hero.cost}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () => _showLargeImage(context, hero.imageUrl),
                child: Card(
                  elevation: 0,
                  color: Colors.transparent,
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: hero.imageUrl,
                    height: 400,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      height: 400,
                      color: Colors.black12,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 400,
                      color: Colors.black12,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Image not available',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Power Stats'),
              StatRow(label: 'Intelligence', value: hero.powerStats.intelligence, color: Colors.blue),
              StatRow(label: 'Strength', value: hero.powerStats.strength, color: Colors.red),
              StatRow(label: 'Speed', value: hero.powerStats.speed, color: Colors.green),
              StatRow(label: 'Durability', value: hero.powerStats.durability, color: Colors.orange),
              StatRow(label: 'Power', value: hero.powerStats.power, color: Colors.purple),
              StatRow(label: 'Combat', value: hero.powerStats.combat, color: Colors.brown),
              
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Biography'),
              _buildInfoRow(context, 'Full Name', hero.fullName),
              _buildInfoRow(context, 'Publisher', hero.publisher),
              _buildInfoRow(context, 'Alignment', hero.alignment),
              
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Connections'),
              _buildInfoRow(context, 'Group Affiliation', hero.groupAffiliation),
              _buildInfoRow(context, 'Relatives', hero.relatives),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text.rich(
        TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  void _showLargeImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
