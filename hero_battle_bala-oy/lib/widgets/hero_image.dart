import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HeroImage extends StatefulWidget {
  const HeroImage({
    super.key,
    required this.urls,
    required this.heroId,
    required this.heroName,
    required this.searchTerms,
    required this.fit,
    required this.loading,
    required this.error,
  });

  final List<String> urls;
  final String heroId;
  final String heroName;
  final List<String> searchTerms;
  final BoxFit fit;
  final Widget loading;
  final Widget error;

  @override
  State<HeroImage> createState() => _HeroImageState();
}

class _HeroImageState extends State<HeroImage> {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      responseType: ResponseType.bytes,
      headers: const {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        'Referer': 'https://www.superherodb.com/',
        'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
      },
    ),
  );

  static final Map<String, Uint8List> _cache = <String, Uint8List>{};
  static Future<Map<String, String>>? _mirrorIndexFuture;

  late Future<Uint8List?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _loadFirstAvailable();
  }

  @override
  void didUpdateWidget(covariant HeroImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.urls.join('|') != widget.urls.join('|')) {
      _imageFuture = _loadFirstAvailable();
    }
  }

  Future<Uint8List?> _loadFirstAvailable() async {
    for (final url in widget.urls) {
      final cached = _cache[url];
      if (cached != null) {
        return cached;
      }

      try {
        final response = await _dio.get<List<int>>(url);
        final bytes = response.data;
        if (bytes == null || bytes.isEmpty) {
          continue;
        }

        final data = Uint8List.fromList(bytes);
        _cache[url] = data;
        return data;
      } catch (_) {
        // Try next candidate URL.
      }
    }

    final mirrorUrl = await _resolveMirrorUrl();
    if (mirrorUrl != null) {
      final cached = _cache[mirrorUrl];
      if (cached != null) {
        return cached;
      }

      try {
        final response = await _dio.get<List<int>>(mirrorUrl);
        final bytes = response.data;
        if (bytes != null && bytes.isNotEmpty) {
          final data = Uint8List.fromList(bytes);
          _cache[mirrorUrl] = data;
          return data;
        }
      } catch (_) {
        // Fall through to error widget.
      }
    }

    return null;
  }

  Future<String?> _resolveMirrorUrl() async {
    _mirrorIndexFuture ??= _loadMirrorIndex();
    final index = await _mirrorIndexFuture!;
    final keys = <String>[
      widget.heroId.trim(),
      _normalizeKey(widget.heroName),
      ...widget.searchTerms.map(_normalizeKey),
    ];

    for (final key in keys) {
      final value = index[key];
      if (value != null && value.isNotEmpty && !value.endsWith('no-portrait.jpg')) {
        return value;
      }
    }

    return null;
  }

  static Future<Map<String, String>> _loadMirrorIndex() async {
    final response = await _dio.get<List<int>>(
      'https://akabab.github.io/superhero-api/api/all.json',
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      return <String, String>{};
    }

    final text = String.fromCharCodes(bytes);
    final decoded = text.isEmpty ? <dynamic>[] : (jsonDecode(text) as List<dynamic>);

    final index = <String, String>{};
    for (final entry in decoded) {
      final map = entry as Map<String, dynamic>;
      final id = map['id']?.toString() ?? '';
      final name = map['name']?.toString() ?? '';
      final images = map['images'] as Map<String, dynamic>?;
      final imageUrl = images?['lg']?.toString() ?? '';
      if (imageUrl.isEmpty) {
        continue;
      }

      index[id] = imageUrl;
      if (name.isNotEmpty) {
        index[_normalizeKey(name)] = imageUrl;
      }

      final biography = map['biography'] as Map<String, dynamic>?;
      final aliases = biography?['aliases'] as List<dynamic>? ?? <dynamic>[];
      for (final alias in aliases) {
        final aliasKey = _normalizeKey(alias.toString());
        if (aliasKey.isNotEmpty) {
          index[aliasKey] = imageUrl;
        }
      }
    }

    return index;
  }

  static String _normalizeKey(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.urls.isEmpty) {
      return widget.error;
    }

    final assetPath = widget.urls.firstWhere(
      (url) => url.startsWith('asset:'),
      orElse: () => '',
    );
    if (assetPath.isNotEmpty) {
      final resolvedAsset = assetPath.replaceFirst('asset:', '');
      if (resolvedAsset.toLowerCase().endsWith('.svg')) {
        return SvgPicture.asset(
          resolvedAsset,
          fit: widget.fit,
        );
      }

      return Image.asset(
        resolvedAsset,
        fit: widget.fit,
      );
    }

    return FutureBuilder<Uint8List?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.loading;
        }

        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return widget.error;
        }

        return Image.memory(
          bytes,
          fit: widget.fit,
          gaplessPlayback: true,
        );
      },
    );
  }
}
