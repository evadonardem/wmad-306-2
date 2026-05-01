import 'dart:convert';
import 'package:adopt_a_dog/models/breed.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BreedDetailScreen extends StatefulWidget {
  final Breed breed;
  const BreedDetailScreen({super.key, required this.breed});

  @override
  State<BreedDetailScreen> createState() => _BreedDetailScreenState();
}

class _BreedDetailScreenState extends State<BreedDetailScreen> {
  late Future<String> _imageFuture;
  String? _selectedSubBreed;

  @override
  void initState() {
    super.initState();
    _imageFuture = _fetchImageUrl();
  }

  Future<String> _fetchImageUrl() async {
    final breedPath = _selectedSubBreed == null
        ? widget.breed.name
        : '${widget.breed.name}/${_selectedSubBreed!}';
    final uri = Uri.parse('https://dog.ceo/api/breed/$breedPath/images/random');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load breed image');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['message'] as String;
  }

  void _selectSubBreed(String? subBreed) {
    setState(() {
      _selectedSubBreed = subBreed;
      _imageFuture = _fetchImageUrl();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.breed.displayName(sub: _selectedSubBreed))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.breed.subBreeds.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.breed.subBreeds.map((subBreed) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(subBreed),
                        selected: _selectedSubBreed == subBreed,
                        onSelected: (_) => _selectSubBreed(subBreed),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: FutureBuilder<String>(
                future: _imageFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Unable to load image. Please try again.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return CachedNetworkImage(
                    imageUrl: snapshot.data!,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
