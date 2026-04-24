import 'package:adopt_a_dog/screens/breed_list_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AdoptADogApp());

class AdoptADogApp extends StatelessWidget {
  const AdoptADogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adopt-a-Dog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const BreedListScreen(),
    );
  }
}
