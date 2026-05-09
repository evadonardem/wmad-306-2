// Neon Noir palette + reusable decoration helpers.
// Imported by main.dart (themes) and the widget layer.

import 'package:flutter/material.dart';

const Color kBgDeep = Color(0xFF0F0F1A);
const Color kSurface = Color(0xFF1A1A2E);
const Color kSurfaceHi = Color(0xFF22223A);
const Color kNeonCyan = Color(0xFF00F5FF);
const Color kNeonMagenta = Color(0xFFC724FF);
const Color kTextPrimary = Colors.white;
const Color kTextDim = Color(0xFFB8B8D1);

/// Cyan-bordered card with a soft outer glow. Used by HeroCard and friends.
BoxDecoration neonBorder({
  Color color = kNeonCyan,
  double radius = 16,
  double width = 1.4,
  double glow = 12,
  Color? fill,
}) {
  return BoxDecoration(
    color: fill ?? kSurface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: color, width: width),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.45),
        blurRadius: glow,
        spreadRadius: 0.5,
      ),
    ],
  );
}

/// Slightly stronger glow used on tap / focus states.
BoxDecoration neonBorderHot({Color color = kNeonMagenta, double radius = 16}) =>
    neonBorder(color: color, radius: radius, width: 2, glow: 22);

const TextStyle kNeonTitle = TextStyle(
  color: kTextPrimary,
  fontWeight: FontWeight.w800,
  letterSpacing: 1.5,
);
