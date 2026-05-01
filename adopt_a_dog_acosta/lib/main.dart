import 'package:flutter/material.dart';
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
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent, // Updated to Blue
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        // Modern rounded design for search bars
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.blue.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIconColor: Colors.blueAccent,
        ),
      ),
      home: const BreedListScreen(),
    );
  }
}