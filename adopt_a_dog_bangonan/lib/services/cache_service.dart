import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CacheService {
  static const _cacheDirName = 'dog_app_cache';
  static const _cacheExpiryHours = 24; // Cache expires after 24 hours
  static const _maxCacheSize = 50 * 1024 * 1024; // 50MB max cache size

  late Directory _cacheDir;
  bool _isInitialized = false;

  CacheService._privateConstructor();
  static final CacheService _instance = CacheService._privateConstructor();
  static CacheService get instance => _instance;

  Future<void> init() async {
    try {
      // Try to get application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory(path.join(appDir.path, _cacheDirName));
    } catch (e) {
      // Fallback to temporary directory if platform doesn't support app documents
      final tempDir = await getTemporaryDirectory();
      _cacheDir = Directory(path.join(tempDir.path, _cacheDirName));
    }
    
    if (!_cacheDir.existsSync()) {
      try {
        _cacheDir.createSync(recursive: true);
      } catch (e) {
        // If we can't create cache directory, disable caching
        _cacheDir = Directory.systemTemp;
      }
    }
    
    _isInitialized = true;
    
    // Clean up old cache files on startup
    await _cleanupOldCacheFiles();
  }

  String _getCacheFilePath(String url) {
    final fileName = Uri.parse(url).pathSegments.last;
    return path.join(_cacheDir.path, fileName);
  }

  bool _isFileExpired(File file) {
    final modified = file.lastModifiedSync();
    final now = DateTime.now();
    final diff = now.difference(modified);
    return diff.inHours > _cacheExpiryHours;
  }

  Future<void> _cleanupOldCacheFiles() async {
    try {
      final files = _cacheDir.listSync();
      final now = DateTime.now();
      
      for (final entity in files) {
        if (entity is File) {
          final modified = entity.lastModifiedSync();
          final diff = now.difference(modified);
          
          if (diff.inHours > _cacheExpiryHours) {
            entity.deleteSync();
          }
        }
      }
      
      // Check total cache size and clean up if too large
      await _enforceCacheSizeLimit();
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  Future<void> _enforceCacheSizeLimit() async {
    try {
      final files = _cacheDir.listSync();
      var totalSize = 0;
      final fileInfos = <MapEntry<File, int>>[];
      
      for (final entity in files) {
        if (entity is File) {
          final size = entity.lengthSync();
          totalSize += size;
          fileInfos.add(MapEntry(entity, entity.lastModifiedSync().millisecondsSinceEpoch));
        }
      }
      
      if (totalSize > _maxCacheSize) {
        // Sort by last modified date (oldest first)
        fileInfos.sort((a, b) => a.value.compareTo(b.value));
        
        // Remove oldest files until we're under the limit
        for (final entry in fileInfos) {
          if (totalSize <= _maxCacheSize) break;
          
          final fileSize = entry.key.lengthSync();
          entry.key.deleteSync();
          totalSize -= fileSize;
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  Future<String?> getCachedImage(String url) async {
    if (!_isInitialized) return null;
    
    try {
      final cachePath = _getCacheFilePath(url);
      final file = File(cachePath);
      
      if (file.existsSync() && !_isFileExpired(file)) {
        return cachePath;
      }
      
      // File doesn't exist or is expired
      if (file.existsSync()) {
        file.deleteSync();
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> cacheImage(String url) async {
    if (!_isInitialized) return null;
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final cachePath = _getCacheFilePath(url);
        final file = File(cachePath);
        await file.writeAsBytes(response.bodyBytes);
        
        // Clean up old files after caching new one
        await _cleanupOldCacheFiles();
        
        return cachePath;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache() async {
    if (!_isInitialized) return;
    
    try {
      if (_cacheDir.existsSync()) {
        final files = _cacheDir.listSync();
        for (final entity in files) {
          if (entity is File) {
            entity.deleteSync();
          }
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  Future<int> getCacheSize() async {
    if (!_isInitialized) return 0;
    
    try {
      if (!_cacheDir.existsSync()) {
        return 0;
      }
      
      final files = _cacheDir.listSync();
      var totalSize = 0;
      
      for (final entity in files) {
        if (entity is File) {
          totalSize += entity.lengthSync();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}