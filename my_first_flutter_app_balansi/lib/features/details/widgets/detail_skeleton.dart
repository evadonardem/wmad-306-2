import 'package:flutter/material.dart';

/// Pulsing placeholder shown while detail data is loading.
class DetailSkeleton extends StatefulWidget {
  const DetailSkeleton({super.key});

  @override
  State<DetailSkeleton> createState() => _DetailSkeletonState();
}

class _DetailSkeletonState extends State<DetailSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _bar({double height = 16, double width = double.infinity}) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Container(
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05 + 0.05 * _ctrl.value),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _bar(height: 28, width: 180),
          _bar(width: 220),
          const SizedBox(height: 16),
          for (var i = 0; i < 6; i++) _bar(),
        ],
      ),
    );
  }
}
