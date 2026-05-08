import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorites_provider.dart';

/// Heart toggle that fills + scales when tapped. Reads its state from the
/// favorites provider so it stays consistent across screens.
class FavoriteHeartButton extends ConsumerWidget {
  const FavoriteHeartButton({
    super.key,
    required this.pokemonId,
    this.size = 28,
    this.color,
  });

  final int pokemonId;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(pokemonId);
    final tint = color ?? const Color(0xFFEF4444);

    return GestureDetector(
      onTap: () => ref.read(favoritesProvider.notifier).toggle(pokemonId),
      behavior: HitTestBehavior.opaque,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFav),
          size: size,
          color: isFav ? tint : Colors.black54,
        ),
      ),
    );
  }
}
