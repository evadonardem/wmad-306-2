import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final player = context.read<PlayerProvider>();
    _controller.text = player.playerName;
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // 🟣 PLAYER NAME
          const Text(
            "Player Name",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter your name",
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              await context
                  .read<PlayerProvider>()
                  .updatePlayerName(_controller.text);

              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text("Name updated!")),
              );
            },
            child: const Text("Save Name"),
          ),

          const SizedBox(height: 24),

          // 🟣 THEME TOGGLE (IMPORTANT)
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Toggle app theme"),
            value: player.isDarkTheme,
            onChanged: (_) {
              context.read<PlayerProvider>().toggleTheme();
            },
          ),

          const SizedBox(height: 24),

          // 🟣 STATS
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text("Total Wins"),
            trailing: Text(player.totalWins.toString()),
          ),
        ],
      ),
    );
  }
}