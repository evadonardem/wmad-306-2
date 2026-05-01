import 'package:adopt_a_dog/screens/breed_list_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AdoptADogApp());
}

class AdoptADogApp extends StatelessWidget {
  const AdoptADogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adopt-a-Dog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.orange,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(  // ← changed CardTheme to CardThemeData
          color: Colors.orange[50],
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        scaffoldBackgroundColor: Colors.amber[50],
        chipTheme: ChipThemeData(
          backgroundColor: Colors.orange[100]!,
          selectedColor: Colors.deepOrange,
          labelStyle: const TextStyle(color: Colors.black),
        ),
      ),
      home: BreedListScreen(),
    );
  }
}