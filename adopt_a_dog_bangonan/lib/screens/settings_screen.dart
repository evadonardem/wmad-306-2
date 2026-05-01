import 'package:adopt_a_dog/services/cache_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<int> _cacheSizeFuture;
  final _cacheService = CacheService.instance;

  @override
  void initState() {
    super.initState();
    _cacheSizeFuture = _cacheService.getCacheSize();
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _clearCache() async {
    await _cacheService.clearCache();
    setState(() {
      _cacheSizeFuture = _cacheService.getCacheSize();
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cache Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Cache size info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.storage, color: Colors.blue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Cache Size',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<int>(
                            future: _cacheSizeFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState != ConnectionState.done) {
                                return const Text('Loading...');
                              }
                              
                              if (snapshot.hasError) {
                                return const Text('Error loading cache size');
                              }
                              
                              final size = snapshot.data ?? 0;
                              return Text(
                                _formatBytes(size),
                                style: TextStyle(
                                  color: size > 10 * 1024 * 1024 ? Colors.orange : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Cache actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cache Actions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // Clear cache button
                    ElevatedButton.icon(
                      onPressed: _clearCache,
                      icon: const Icon(Icons.delete),
                      label: const Text('Clear Cache'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Cache info
                    const Text(
                      'Clearing the cache will remove all downloaded images and breed data. They will be re-downloaded when needed.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // App info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Information',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text('Adopt a Dog App'),
                    const SizedBox(height: 4),
                    const Text('Version: 1.0.0'),
                    const SizedBox(height: 4),
                    Text('Platform: ${Platform.operatingSystem}'),
                    const SizedBox(height: 4),
                    const Text('Cache Location: Local Storage'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}