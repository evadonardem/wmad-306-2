import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'router/app_router.dart';
import 'providers/player_provider.dart';
import 'providers/deck_provider.dart';
import 'providers/battle_provider.dart';
import 'providers/hero_search_provider.dart';
import 'services/superhero_api_service.dart';

const String kApiToken = '5fe6687dee0ff8de37ee4488bbaa81a9';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const HeroBattleApp());
}

class HeroBattleApp extends StatelessWidget {
  const HeroBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = SuperheroApiService(apiToken: kApiToken);

    return MultiProvider(
      providers: [
        Provider<SuperheroApiService>.value(value: apiService),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => DeckProvider()),
        ChangeNotifierProvider(create: (_) => BattleProvider()),
        ChangeNotifierProvider(create: (_) => HeroSearchProvider(apiService)),
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

  ThemeData _baseTheme(Brightness brightness) {
    final base = ThemeData(
      colorSchemeSeed: const Color(0xFF7B2FBE),
      brightness: brightness,
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: GoogleFonts.dotGothic16TextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.pixelifySans(textStyle: base.textTheme.displayLarge),
        displayMedium: GoogleFonts.pixelifySans(textStyle: base.textTheme.displayMedium),
        displaySmall: GoogleFonts.pixelifySans(textStyle: base.textTheme.displaySmall),
        headlineLarge: GoogleFonts.pixelifySans(textStyle: base.textTheme.headlineLarge),
        headlineMedium: GoogleFonts.pixelifySans(textStyle: base.textTheme.headlineMedium),
        headlineSmall: GoogleFonts.pixelifySans(textStyle: base.textTheme.headlineSmall),
        titleLarge: GoogleFonts.pixelifySans(textStyle: base.textTheme.titleLarge),
        titleMedium: GoogleFonts.pixelifySans(textStyle: base.textTheme.titleMedium),
        titleSmall: GoogleFonts.pixelifySans(textStyle: base.textTheme.titleSmall),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: GoogleFonts.pixelifySans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  ThemeData _darkTheme() => _baseTheme(Brightness.dark);
  ThemeData _lightTheme() => _baseTheme(Brightness.light);
}
