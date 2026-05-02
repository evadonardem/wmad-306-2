import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../router/app_router.dart';
import '../../services/prefs_service.dart';


class SplashScreen extends StatefulWidget {
const SplashScreen({super.key});
@override State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
final PrefsService _prefsService = PrefsService();

@override
void initState() {
super.initState();
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;
  _init();
});
}
Future<void> _init() async {
// Load preferences into PlayerProvider before showing any screen
await context.read<PlayerProvider>().loadFromPrefs();
final isOnboarded = await _prefsService.isOnboarded();
if (!mounted) return;
// Replace splash so the user cannot pop back to it
final nextRoute = isOnboarded ? RouteNames.home : RouteNames.deck;
if (!isOnboarded) {
  await _prefsService.setOnboarded();
}
if (!mounted) return;
Navigator.pushReplacementNamed(context, nextRoute);
}
@override
Widget build(BuildContext context) {
return const Scaffold(
body: Center(child: CircularProgressIndicator()),
);
}
}
