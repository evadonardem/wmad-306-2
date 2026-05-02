import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Consumer<PlayerProvider>(
              builder: (context, playerProvider, child) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark theme'),
                  value: playerProvider.isDarkTheme,
                  onChanged: (value) {
                    playerProvider.toggleTheme();
                  },
                  secondary: Icon(
                    playerProvider.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
