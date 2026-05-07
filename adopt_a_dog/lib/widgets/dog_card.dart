import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/dog.dart';
import '../theme/app_theme.dart';

/// Tactile gallery card with hero image, ribbon trait, and press scale-down.
class DogCard extends StatefulWidget {
  const DogCard({
    super.key,
    required this.dog,
    required this.onTap,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final DogSummary dog;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  State<DogCard> createState() => _DogCardState();
}

class _DogCardState extends State<DogCard> {
  bool _pressed = false;
  bool _lifted = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  void _setLifted(bool v) {
    if (_lifted == v) return;
    setState(() => _lifted = v);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.95 : (_lifted ? 1.03 : 1.0);
    final shadowOpacity = _lifted ? 0.18 : (_pressed ? 0.04 : 0.08);

    return MouseRegion(
      onEnter: (_) => _setLifted(true),
      onExit: (_) => _setLifted(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        onLongPress: () => _setLifted(true),
        onLongPressEnd: (_) => _setLifted(false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardOutline),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: shadowOpacity),
                  blurRadius: _lifted ? 22 : 12,
                  offset: Offset(0, _lifted ? 12 : 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _photo(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: _info(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _photo() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'dog-photo-${widget.dog.id}',
            child: CachedNetworkImage(
              imageUrl: widget.dog.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.cardOutline),
              errorWidget: (_, _, _) =>
                  Container(color: AppColors.cardOutline),
            ),
          ),
          // Subtle gradient so the bottom edge of the photo sits cleanly
          // against the white card area below.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _favoriteButton(),
          ),
        ],
      ),
    );
  }

  Widget _favoriteButton() {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onToggleFavorite();
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(widget.isFavorite),
              color: widget.isFavorite
                  ? AppColors.terracotta
                  : AppColors.inkSoft,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.dog.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.dog.breed,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.inkSoft,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _miniIcon(Icons.cake_outlined, '${widget.dog.age}y'),
            const SizedBox(width: 10),
            _miniIcon(Icons.straighten, widget.dog.size),
          ],
        ),
      ],
    );
  }

  Widget _miniIcon(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.forestSoft),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.forestSoft,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
