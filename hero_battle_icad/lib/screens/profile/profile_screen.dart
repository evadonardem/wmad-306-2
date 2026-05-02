import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Player Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Toggle (Exercise 3) [cite: 472]
          Consumer<PlayerProvider>(
            builder: (context, player, child) {
              return ListTile(
                title: const Text("Dark Mode"),
                trailing: Switch(
                  value: player.isDarkTheme,
                  onChanged: (val) => player.toggleTheme(),
                ),
              );
            },
          ),
          const Divider(),
          // Player Name Update [cite: 422-423]
          ListTile(
            title: const Text("Player Name"),
            subtitle: Text(context.watch<PlayerProvider>().playerName),
            onTap: () => _showNameDialog(context),
            trailing: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  void _showNameDialog(BuildContext context) {
    final controller = TextEditingController(text: context.read<PlayerProvider>().playerName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Name"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              context.read<PlayerProvider>().updatePlayerName(controller.text);
              Navigator.pop(context);
            }, 
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}