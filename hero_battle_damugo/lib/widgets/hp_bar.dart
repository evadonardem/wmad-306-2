import 'package:flutter/material.dart';

class HpBar extends StatefulWidget {
  const HpBar({
    super.key,
    required this.label,
    required this.current,
    required this.max,
    required this.color,
  });

  final String label;
  final int current;
  final int max;
  final Color color;

  @override
  State<HpBar> createState() => _HpBarState();
}

class _HpBarState extends State<HpBar> {
  @override
  Widget build(BuildContext context) {
    final value = widget.max <= 0
        ? 0.0
        : (widget.current / widget.max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${widget.label}: ${widget.current} / ${widget.max}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: const <Shadow>[
              Shadow(
                blurRadius: 6,
                color: Colors.black,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          tween: Tween<double>(begin: value, end: value),
          builder: (context, tweenValue, child) {
            return LinearProgressIndicator(
              value: tweenValue,
              minHeight: 10,
              color: widget.color,
              backgroundColor: widget.color.withAlpha(51),
              borderRadius: BorderRadius.circular(6),
            );
          },
        ),
      ],
    );
  }
}
