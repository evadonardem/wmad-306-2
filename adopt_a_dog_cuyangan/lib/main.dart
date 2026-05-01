import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/breed_list_screen.dart';

void main() => runApp(const AdoptADogApp());

class AdoptADogApp extends StatelessWidget {
  const AdoptADogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adopt-a-Dog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1B5E20), // Deep royal green
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20), // Deep royal green
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32), // Medium royal green
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF4CAF50)), // Light green
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2), // Medium green focus
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIconColor: const Color(0xFF4CAF50), // Light green icon
        ),
        listTileTheme: const ListTileThemeData(
          leadingAndTrailingTextStyle: TextStyle(color: Color(0xFF1B5E20)),
          iconColor: Color(0xFF2E7D32), // Medium green icons
          titleTextStyle: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF2E7D32), // Medium green icons
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: kIsWeb ? const WebScaffold() : const BreedListScreen(),
    );
  }
}

class WebScaffold extends StatelessWidget {
  const WebScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: const Column(
        children: [
          // Main content
          Expanded(
            child: BreedListScreen(),
          ),
          // Web footer
          WebFooter(),
        ],
      ),
    );
  }
}

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20), // Deep royal green
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Adopt-a-Dog',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Find your perfect companion',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.copyright,
                color: Colors.white70,
                size: 12,
              ),
              SizedBox(width: 4),
              Text(
                '2026 Developed by Lryn Cuyangan',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Built with Flutter & Dog CEO API',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}
