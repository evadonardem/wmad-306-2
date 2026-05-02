import 'package:flutter/material.dart';
import '../screens/main/main_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/battle/battle_screen.dart';
import '../models/hero_model.dart';

class RouteNames {
  static const String splash = '/';
  static const String home = '/home';
  static const String battle = '/battle';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case RouteNames.battle:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BattleScreen(
            playerTeam: args['playerTeam'] as List<HeroModel>,
            aiTeam: args['aiTeam'] as List<HeroModel>,
            aiName: args['aiName'] as String,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
