import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'breed_list_screen.dart';
import 'community_feed_screen.dart';
import 'explore_masonry_screen.dart';
import 'favorites_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const BreedListScreen(),
      const FavoritesScreen(),
      const ExploreMasonryScreen(),
      const CommunityFeedScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6200EE),
        unselectedItemColor: const Color(0xFF757575),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            selectedColor: Colors.deepOrange,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.favorite_border),
            title: const Text('Likes'),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.grid_view_rounded),
            title: const Text('Explore'),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.dynamic_feed_outlined),
            title: const Text('Feed'),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
