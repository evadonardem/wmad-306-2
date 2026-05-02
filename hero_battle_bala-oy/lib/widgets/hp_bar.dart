import 'package:flutter/material.dart';

class HpBar extends StatefulWidget {
  const HpBar({
    super.key,
    required this.label,
    required this.current,
    required this.max,
    required this.color,
    this.currentMana,
    this.maxMana,
  });

  final String label;
  final int current;
  final int max;
  final Color color;
  final int? currentMana;
  final int? maxMana;

  @override
  State<HpBar> createState() => _HpBarState();
}

class _HpBarState extends State<HpBar> {
  @override
  Widget build(BuildContext context) {
    final hpValue = widget.max <= 0
        ? 0.0
        : (widget.current / widget.max).clamp(0.0, 1.0);
    
    final manaValue = widget.maxMana == null || widget.maxMana! <= 0
        ? 0.0
        : (widget.currentMana! / widget.maxMana!).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${widget.label}: ${widget.current} / ${widget.max}${widget.currentMana != null ? ' | Mana: ${widget.currentMana} / ${widget.maxMana}' : ''}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            shadows: const <Shadow>[
              Shadow(blurRadius: 6, color: Colors.black, offset: Offset(0, 1)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          tween: Tween<double>(begin: hpValue, end: hpValue),
          builder: (context, tweenValue, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: tweenValue,
                minHeight: 14,
                valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                backgroundColor: widget.color.withAlpha(80),
                semanticsLabel: '${widget.label} health',
              ),
            );
          },
        ),
        if (widget.currentMana != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              tween: Tween<double>(begin: manaValue, end: manaValue),
              builder: (context, tweenValue, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: tweenValue,
                    minHeight: 10,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent.shade200),
                    backgroundColor: Colors.cyan.withAlpha(60),
                    semanticsLabel: '${widget.label} mana',
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
