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
        // Primary colors and Material 3
        colorSchemeSeed: const Color(0xFF2E7D32),
        useMaterial3: true,

        // AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 4,
        ),

        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF388E3C),
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Input field theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          prefixIconColor: const Color(0xFF4CAF50),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),

        // ListTile theme
        listTileTheme: const ListTileThemeData(
          iconColor: Color(0xFF2E7D32),
          textColor: Color(0xFF212121),
          tileColor: Colors.white,
        ),

        // Icon theme
        iconTheme: const IconThemeData(color: Color(0xFF2E7D32)),

        // Card theme
        cardTheme: const CardThemeData(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
      home: kIsWeb ? const WebScaffold() : const BreedListScreen(),
    );
  }
}

// Web scaffold with footer
class WebScaffold extends StatefulWidget {
  const WebScaffold({super.key});

  @override
  State<WebScaffold> createState() => _WebScaffoldState();
}

class _WebScaffoldState extends State<WebScaffold>
    with TickerProviderStateMixin {
  late AnimationController _footerController;

  @override
  void initState() {
    super.initState();
    _footerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E8), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const Expanded(child: BreedListScreen()),
            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _footerController,
                      curve: Curves.easeOut,
                    ),
                  ),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _footerController,
                    curve: Curves.easeIn,
                  ),
                ),
                child: const WebFooter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Web footer
class WebFooter extends StatefulWidget {
  const WebFooter({super.key});

  @override
  State<WebFooter> createState() => _WebFooterState();
}

class _WebFooterState extends State<WebFooter> with TickerProviderStateMixin {
  late AnimationController _textController;
  late AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: _textController, curve: Curves.easeIn),
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1).animate(
                CurvedAnimation(
                  parent: _textController,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: const Text(
                'Adopt-a-Dog',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: _textController, curve: Curves.easeIn),
            ),
            child: const Text(
              'Find your perfect companion',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1).animate(
              CurvedAnimation(
                parent: _iconController,
                curve: Curves.elasticOut,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.copyright, size: 12, color: Colors.white70),
                SizedBox(width: 4),
                Text(
                  '2026 Developed by Aquisan, Joven Paulo G.',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: _textController, curve: Curves.easeIn),
            ),
            child: const Text(
              'Built with Flutter & Dog CEO API',
              style: TextStyle(fontSize: 8, color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }
}
