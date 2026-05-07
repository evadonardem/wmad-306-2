import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dogs_provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// Holds the bottom navigation and its three tabs.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Kick off initial loads as soon as the shell mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DogsProvider>().load();
      context.read<FavoritesProvider>().hydrate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      HomeScreen(),
      FavoritesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.cardOutline, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.pets_outlined),
              activeIcon: Icon(Icons.pets),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
