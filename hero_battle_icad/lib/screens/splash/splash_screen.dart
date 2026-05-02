import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 1. Start a 2-second timer so the user sees the splash
    final timer = Future.delayed(const Duration(seconds: 2));

    try {
      // 2. Try to load player data
      await context.read<PlayerProvider>().loadFromPrefs();
    } catch (e) {
      print("Error loading prefs: $e"); // This will show in your console
    }

    // 3. Wait for the timer to finish if the data loaded too fast
    await timer;

    if (!mounted) return;
    
    // 4. Go to Home
    Navigator.pushReplacementNamed(context, RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}