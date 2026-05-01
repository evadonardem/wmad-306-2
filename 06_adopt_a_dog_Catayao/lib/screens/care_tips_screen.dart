import 'package:flutter/material.dart';

class CareTipsScreen extends StatelessWidget {
  const CareTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text(
                'Dog Care Guide',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Quick reminders to help future adopters stay prepared, thoughtful, and consistent.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              const _TipCard(
                icon: Icons.restaurant_rounded,
                title: 'Daily essentials',
                content:
                    'Keep fresh water available, feed on a regular schedule, and choose food appropriate for the dog\'s age and size.',
                color: Color(0xFFFFCC80),
              ),
              const _TipCard(
                icon: Icons.health_and_safety_rounded,
                title: 'Health first',
                content:
                    'Schedule regular vet visits, stay up to date on vaccines, and watch for changes in energy, appetite, or behavior.',
                color: Color(0xFFFFAB91),
              ),
              const _TipCard(
                icon: Icons.directions_walk_rounded,
                title: 'Exercise matters',
                content:
                    'Most breeds need regular walks, play, and mental stimulation. Match activity levels to the breed you choose.',
                color: Color(0xFFFFE082),
              ),
              const _TipCard(
                icon: Icons.clean_hands_rounded,
                title: 'Grooming routine',
                content:
                    'Brush the coat, keep nails trimmed, and clean ears when needed. Grooming frequency depends on breed and coat type.',
                color: Color(0xFFBCAAA4),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Before You Adopt',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _ChecklistRow(
                      text: 'Check your available time each day',
                    ),
                    const _ChecklistRow(
                      text: 'Plan your monthly food and vet budget',
                    ),
                    const _ChecklistRow(
                      text: 'Make room for training and patience',
                    ),
                    const _ChecklistRow(
                      text: 'Choose a breed that matches your lifestyle',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final String text;

  const _ChecklistRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFEF6C00), size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
