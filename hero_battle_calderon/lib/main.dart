import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'router/app_router.dart';
import 'providers/player_provider.dart';
import 'providers/deck_provider.dart';
import 'providers/battle_provider.dart';
import 'providers/battle_history_provider.dart';
import 'providers/hero_selection_provider.dart';
import 'providers/hero_search_provider.dart';
import 'services/superhero_api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize FFI
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
        Provider(
          create: (_) => SuperheroApiService(
            apiToken: 'Lrnz Token',
          ),
        ),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => DeckProvider()),
        ChangeNotifierProvider(create: (_) => BattleProvider()),
        ChangeNotifierProvider(create: (_) => BattleHistoryProvider()),
        ChangeNotifierProxyProvider<SuperheroApiService, HeroSelectionProvider>(
          create: (context) => HeroSelectionProvider(
            context.read<SuperheroApiService>(),
          ),
          update: (context, api, previous) => previous ?? HeroSelectionProvider(api),
        ),
        ChangeNotifierProxyProvider<SuperheroApiService, HeroSearchProvider>(
          create: (context) => HeroSearchProvider(
            context.read<SuperheroApiService>(),
          ),
          update: (context, api, previous) => previous ?? HeroSearchProvider(api),
        ),
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
        colorSchemeSeed: const Color.fromARGB(255, 12, 10, 136),
        brightness: Brightness.dark,
        useMaterial3: true,
      );

  ThemeData _lightTheme() => ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 61, 233, 233),
        brightness: Brightness.light,
        useMaterial3: true,
      );
}
