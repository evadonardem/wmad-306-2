import 'package:flutter/material.dart';

void main() {
  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My First Flutter App Hunas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int count = 0;

  void increase() => setState(() => count++);
  void decrease() => setState(() {
        if (count > 0) count--;
      });
  void reset() => setState(() => count = 0);

  Color getCounterColor() {
    if (count == 0) return Colors.grey;
    if (count < 5) return Colors.blue;
    if (count < 10) return Colors.orange;
    return Colors.red;
  }

  String getStatus() {
    if (count == 0) return "Start counting!";
    if (count < 5) return "Keep going 👍";
    if (count < 10) return "Nice progress 🔥";
    return "You're on fire 🚀";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hunas Counter App"),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getStatus(),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Counter Display Card
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: getCounterColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$count",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: getCounterColor(),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton(
                  icon: Icons.remove,
                  onTap: count > 0 ? decrease : null,
                ),
                const SizedBox(width: 15),
                _buildButton(
                  icon: Icons.refresh,
                  onTap: reset,
                ),
                const SizedBox(width: 15),
                _buildButton(
                  icon: Icons.add,
                  onTap: increase,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, VoidCallback? onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(18),
      ),
      child: Icon(icon, size: 28),
    );
  }
}