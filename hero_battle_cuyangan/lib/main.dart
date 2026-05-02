import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'providers/deck_provider.dart';
import 'providers/battle_provider.dart';
import 'providers/player_provider.dart';
import 'providers/hero_search_provider.dart';
import 'providers/battle_history_provider.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const HeroBattleApp());
}

class HeroBattleApp extends StatelessWidget {
  const HeroBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => DeckProvider()),
        ChangeNotifierProvider(create: (_) => BattleProvider()),
        ChangeNotifierProvider(create: (_) => HeroSearchProvider()),
        ChangeNotifierProvider(create: (_) => BattleHistoryProvider()),
      ],
      child: Consumer<PlayerProvider>(
        builder: (context, player, _) {
          return MaterialApp(
            title: 'Hero Battle',
            debugShowCheckedModeBanner: false,
            theme: player.isDarkTheme ? _darkTheme() : _lightTheme(),
            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }

  ThemeData _darkTheme() => ThemeData(
    colorSchemeSeed: const Color(0xFF7B2FBE),
    brightness: Brightness.dark,
    useMaterial3: true,
  );

  ThemeData _lightTheme() => ThemeData(
    colorSchemeSeed: const Color(0xFF7B2FBE),
    brightness: Brightness.light,
    useMaterial3: true,
  );
}
