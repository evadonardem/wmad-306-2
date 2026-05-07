// Strategist Hero Card — neon portrait, top-3 stats, and the
// "fly to deck" overlay animation when Add to Deck is tapped.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/hero_model.dart';
import '../providers/deck_provider.dart';
import '../router/app_router.dart';
import '_neon.dart';

class HeroCard extends StatefulWidget {
  final HeroModel hero;
  const HeroCard({super.key, required this.hero});

  @override
  State<HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<HeroCard> {
  final GlobalKey _imgKey = GlobalKey();
  bool _pressed = false;

  void _flyToDeck() {
    // Capture the portrait position before mutating provider state.
    final ctx = _imgKey.currentContext;
    final overlay = Overlay.maybeOf(context);
    if (ctx == null || overlay == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;

    final start = box.localToGlobal(Offset.zero);
    final size = box.size;
    final screen = MediaQuery.of(context).size;
    // The deck badge lives in the AppBar at top-right.
    final end = Offset(screen.width - 36, 36);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FlyingHero(
        imageUrl: widget.hero.imageUrl,
        start: start,
        end: end,
        startSize: size,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final hero = widget.hero;
    final top3 = hero.powerStats.sortedEntries().take(3).toList();

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () => Navigator.pushNamed(
        context,
        RouteNames.heroDetail,
        arguments: hero,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(8),
        decoration: _pressed
            ? neonBorderHot()
            : neonBorder(color: kNeonCyan, glow: 8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    key: _imgKey,
                    color: kSurfaceHi,
                    child: CachedNetworkImage(
                      imageUrl: hero.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kNeonCyan,
                        ),
                      ),
                      errorWidget: (_, _, _) => const Icon(
                        Icons.broken_image,
                        color: kNeonMagenta,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hero.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kNeonTitle.copyWith(fontSize: 14),
              ),
              if (hero.publisher.isNotEmpty)
                Text(
                  hero.publisher,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: kTextDim, fontSize: 11),
                ),
              const SizedBox(height: 6),
              // Top-3 stats — picked dynamically from PowerStats.
              ...top3.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          style: const TextStyle(
                            color: kTextDim,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${e.value}',
                        style: const TextStyle(
                          color: kNeonCyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Narrow Consumer — only this button rebuilds on deck change.
              Consumer<DeckProvider>(
                builder: (context, deck, _) {
                  final inDeck = deck.contains(hero);
                  final disabled = !inDeck && deck.isFull;
                  return SizedBox(
                    height: 30,
                    child: ElevatedButton.icon(
                      onPressed: disabled
                          ? null
                          : () {
                              if (inDeck) {
                                deck.removeHero(hero);
                              } else {
                                _flyToDeck();
                                deck.addHero(hero);
                              }
                            },
                      icon: Icon(
                        inDeck ? Icons.remove : Icons.add,
                        size: 16,
                      ),
                      label: Text(
                        inDeck ? 'Remove' : 'Add',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            inDeck ? kNeonMagenta : kNeonCyan,
                        foregroundColor: kBgDeep,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Overlay widget: clones the hero portrait and animates it toward the
/// deck icon in the AppBar. Custom flutter_animate sequence.
class _FlyingHero extends StatelessWidget {
  final String imageUrl;
  final Offset start;
  final Offset end;
  final Size startSize;
  final VoidCallback onDone;

  const _FlyingHero({
    required this.imageUrl,
    required this.start,
    required this.end,
    required this.startSize,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;

    final flying = Container(
      width: startSize.width,
      height: startSize.height,
      decoration: neonBorderHot(radius: 12),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) =>
            const Icon(Icons.bolt, color: kNeonCyan),
      ),
    )
        .animate(onComplete: (_) => onDone())
        .move(
          duration: 650.ms,
          curve: Curves.easeInCubic,
          end: Offset(dx, dy),
        )
        .scaleXY(end: 0.18, duration: 650.ms, curve: Curves.easeIn)
        .fadeOut(delay: 450.ms, duration: 200.ms);

    return Positioned(
      left: start.dx,
      top: start.dy,
      child: IgnorePointer(child: flying),
    );
  }
}
