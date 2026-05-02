import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/hero_model.dart';
import '../router/app_router.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.hero});
  final HeroModel hero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, RouteNames.heroDetail, arguments: hero),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: hero.imageUrl.isNotEmpty
                  ? _HeroImage(imageUrl: hero.imageUrl, heroName: hero.name)
                  : _placeholder(hero.name),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hero.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'HP: ${hero.maxHp}  ATK: ${hero.attack}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(String name) {
    return Container(
      color: Colors.purple.shade900,
      child: Center(
        child: Text(
          name[0],
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatefulWidget {
  const _HeroImage({required this.imageUrl, required this.heroName});
  final String imageUrl;
  final String heroName;

  @override
  State<_HeroImage> createState() => _HeroImageState();
}

class _HeroImageState extends State<_HeroImage> {
  static final _dio = Dio();
  static final _cache = <String, Uint8List>{};

  Uint8List? _imageBytes;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    // Check cache first
    if (_cache.containsKey(widget.imageUrl)) {
      if (mounted) {
        setState(() {
          _imageBytes = _cache[widget.imageUrl];
          _loading = false;
        });
      }
      return;
    }

    try {
      // Use image proxy to bypass hotlink protection
      final proxyUrl = 'https://corsproxy.io/?${Uri.encodeComponent(widget.imageUrl)}';

      final response = await _dio.get<List<int>>(
        proxyUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'User-Agent': 'Mozilla/5.0',
          },
        ),
      );

      if (response.data != null && mounted) {
        final bytes = Uint8List.fromList(response.data!);
        _cache[widget.imageUrl] = bytes;
        setState(() {
          _imageBytes = bytes;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Image load error: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error || _imageBytes == null) {
      return Container(
        color: Colors.purple.shade900,
        child: Center(
          child: Text(
            widget.heroName[0],
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Image.memory(
      _imageBytes!,
      fit: BoxFit.cover,
    );
  }
}