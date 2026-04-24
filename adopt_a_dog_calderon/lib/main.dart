import 'dart:ui';
import 'package:flutter/material.dart';
import 'screens/breed_list_screen.dart';

void main() => runApp(const AdoptADogApp());

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class AdoptADogApp extends StatelessWidget {
  const AdoptADogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adopt-a-Dog',
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEAFFD0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF38181),
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF38181),
          primary: const Color(0xFFF38181),
          secondary: const Color(0xFFFCE38A),
          tertiary: const Color(0xFFEAFFD0),
        ).copyWith(secondaryContainer: const Color(0xFF95E1D3)),
      ),
      home: const BreedListScreen(),
    );
  }
}
