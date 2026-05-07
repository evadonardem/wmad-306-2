// Manual §5.6 — Splash. Loads PlayerProvider from prefs, then replaces
// itself with Home. Custom: neon "HERO BATTLE" title with shimmer.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../providers/player_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/_neon.dart';

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
    // Load preferences into PlayerProvider before showing any screen.
    await context.read<PlayerProvider>().loadFromPrefs();
    // Slight pause so the title animation can play.
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDeep,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'HERO',
              style: kNeonTitle.copyWith(
                fontSize: 56,
                color: kNeonCyan,
                shadows: [
                  Shadow(
                    color: kNeonCyan.withValues(alpha: 0.8),
                    blurRadius: 18,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slide(begin: const Offset(-0.2, 0)),
            Text(
              'BATTLE',
              style: kNeonTitle.copyWith(
                fontSize: 56,
                color: kNeonMagenta,
                shadows: [
                  Shadow(
                    color: kNeonMagenta.withValues(alpha: 0.8),
                    blurRadius: 18,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms)
                .slide(begin: const Offset(0.2, 0))
                .then()
                .shimmer(duration: 800.ms, color: kNeonCyan),
            const SizedBox(height: 32),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: kNeonCyan,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
