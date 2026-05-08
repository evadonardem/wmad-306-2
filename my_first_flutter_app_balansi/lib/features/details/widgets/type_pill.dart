import 'package:flutter/material.dart';

import '../../../core/theme/pokemon_type_color.dart';
import '../../../core/utils/string_ext.dart';

/// A rounded chip displaying a single Pokémon type, colored to match.
class TypePill extends StatelessWidget {
  const TypePill({super.key, required this.type, this.compact = false});

  final String type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = PokemonTypeColor.of(type);
    final fg = PokemonTypeColor.onAccent(type);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        type.capitalize(),
        style: TextStyle(
          color: fg,
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
