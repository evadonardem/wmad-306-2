import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../services/dog_api_service.dart';
import 'breed_detail_screen.dart';

class AdoptedScreen extends StatefulWidget {
  const AdoptedScreen({super.key});

  @override
  State<AdoptedScreen> createState() => _AdoptedScreenState();
}

class _AdoptedScreenState extends State<AdoptedScreen> {
  final _prefs = PrefsService();
  final _api = DogApiService();
  List<String> _adopted = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    _adopted = await _prefs.loadAdopted();
    setState(() {});
  }

  void _openDetail(String name) async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    final breed = await _api.findBreedByName(name);
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => BreedDetailScreen(breed: breed)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adopted Dogs')),
      body: _adopted.isEmpty
          ? const Center(child: Text('You haven\'t adopted any dogs yet!'))
          : ListView.builder(
              itemCount: _adopted.length,
              itemBuilder: (context, index) {
                final name = _adopted[index];
                return ListTile(
                  leading: const Icon(Icons.verified, color: Colors.green),
                  title: Text(name[0].toUpperCase() + name.substring(1)),
                  onTap: () => _openDetail(name), // Made functional
                );
              },
            ),
    );
  }
}