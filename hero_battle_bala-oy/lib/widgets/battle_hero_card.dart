import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/hero_model.dart';
import '../widgets/hero_image.dart';

class BattleHeroCard extends StatelessWidget {
  const BattleHeroCard({super.key, required this.hero, required this.isPlayer});

  final HeroModel hero;
  final bool isPlayer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statTextStyle = textTheme.titleLarge!.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      shadows: [
        const Shadow(
          blurRadius: 2.0,
          color: Colors.black,
          offset: Offset(1.0, 1.0),
        ),
      ],
    );

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPlayer
              ? Colors.greenAccent.shade400
              : Colors.deepPurpleAccent.shade200,
          width: 3,
        ),
      ),
      child: SizedBox(
        width: 260,
        height: 340, // Increased height for new design
        child: Stack(
          children: <Widget>[
            // Background Image
            Positioned.fill(
              child: HeroImage(
                urls: hero.displayImageCandidates,
                heroId: hero.id,
                heroName: hero.name,
                searchTerms: hero.imageSearchTerms,
                fit: BoxFit.cover,
                loading: const ColoredBox(color: Colors.black26),
                error: const ColoredBox(
                  color: Colors.black45,
                  child: Icon(Icons.broken_image, color: Colors.white24),
                ),
              ),
            ),
            // Gradient overlay for text readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(102),
                      Colors.black.withAlpha(204),
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 34, 10, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        hero.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headlineMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            const Shadow(
                              blurRadius: 4.0,
                              color: Colors.black,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _StatGem(
                            value: hero.attack,
                            color: Colors.red.shade800,
                            textStyle: statTextStyle,
                          ),
                          _StatGem(
                            value: hero.defense,
                            color: Colors.blue.shade800,
                            textStyle: statTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatGem extends StatelessWidget {
  const _StatGem({
    required this.value,
    required this.color,
    required this.textStyle,
  });

  final int value;
  final Color color;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HexagonPainter(color: color),
      child: SizedBox(
        width: 48,
        height: 52,
        child: Center(child: Text(value.toString(), style: textStyle)),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Color color;

  _HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const angle = (math.pi * 2) / 6;

    path.moveTo(
      centerX + size.width / 2 * math.cos(0),
      centerY + size.height / 2 * math.sin(0),
    );

    for (var i = 1; i <= 6; i++) {
      path.lineTo(
        centerX + size.width / 2 * math.cos(angle * i),
        centerY + size.height / 2 * math.sin(angle * i),
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
