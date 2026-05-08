import 'package:flutter/material.dart';

/// Canonical Pokémon type → accent color mapping plus pastel-background helper.
class PokemonTypeColor {
  PokemonTypeColor._();

  static const Map<String, Color> _accents = {
    'normal':   Color(0xFFA8A878),
    'fire':     Color(0xFFF08030),
    'water':    Color(0xFF6890F0),
    'grass':    Color(0xFF78C850),
    'electric': Color(0xFFF8D030),
    'ice':      Color(0xFF98D8D8),
    'fighting': Color(0xFFC03028),
    'poison':   Color(0xFFA040A0),
    'ground':   Color(0xFFE0C068),
    'flying':   Color(0xFFA890F0),
    'psychic':  Color(0xFFF85888),
    'bug':      Color(0xFFA8B820),
    'rock':     Color(0xFFB8A038),
    'ghost':    Color(0xFF705898),
    'dragon':   Color(0xFF7038F8),
    'dark':     Color(0xFF705848),
    'steel':    Color(0xFFB8B8D0),
    'fairy':    Color(0xFFEE99AC),
  };

  /// Returns the saturated accent color for [typeName]; defaults to Normal.
  static Color of(String typeName) {
    return _accents[typeName.toLowerCase()] ?? _accents['normal']!;
  }

  /// Returns a soft pastel version suitable for backgrounds — accent blended
  /// ~80 % toward white.
  static Color pastel(String typeName) {
    final c = of(typeName);
    return Color.lerp(c, Colors.white, 0.78)!;
  }

  /// Returns a foreground color (black/white) with sufficient contrast against
  /// the accent for [typeName].
  static Color onAccent(String typeName) {
    final c = of(typeName);
    final luminance = c.computeLuminance();
    return luminance > 0.55 ? Colors.black87 : Colors.white;
  }
}
