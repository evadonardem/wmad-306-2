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
   
        colorSchemeSeed: const Color(0xFFF06292),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDEEF5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 96, 76, 175),
     
          foregroundColor: Color.fromARGB(255, 164, 81, 81),
          elevation: 0,
        ),
        listTileTheme: const ListTileThemeData(
        
          iconColor: Color.fromARGB(255, 64, 60, 123),
          textColor: Color.fromARGB(255, 107, 240, 98),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
      ),
      home: BreedListScreen(),
    );
  }
}