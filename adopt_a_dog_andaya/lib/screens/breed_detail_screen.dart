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
  static const _apiBase = 'https://dog.ceo/api';

  late Future<String> _imageFuture;
  String? _selectedSubBreed;

  @override
  void initState() {
    super.initState();
    _imageFuture = _fetchImageUrl();
  }

  Future<String> _fetchImageUrl([String? subBreed]) async {
    final breedPath = subBreed != null && subBreed.isNotEmpty
        ? '${widget.breed.name}/$subBreed'
        : widget.breed.name;
    final uri = Uri.parse('$_apiBase/breed/$breedPath/images/random');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['message'] as String;
  }

  void _selectSubBreed(String? subBreed) {
    setState(() {
      _selectedSubBreed = subBreed;
      _imageFuture = _fetchImageUrl(subBreed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.breed.displayName(sub: _selectedSubBreed);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.breed.subBreeds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.breed.subBreeds.map((subBreed) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(subBreed),
                        selected: _selectedSubBreed == subBreed,
                        onSelected: (selected) => _selectSubBreed(selected ? subBreed : null),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<String>(
              future: _imageFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Unable to load image. Please try again.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                }

                final imageUrl = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, size: 64)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
