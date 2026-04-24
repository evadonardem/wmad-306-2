import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DogImageViewer extends StatelessWidget {
  const DogImageViewer({super.key, required this.imageUrl, this.height});

  final String imageUrl;
  final double? height;

  void _openZoomViewer(BuildContext context, ImageProvider imageProvider) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image(image: imageProvider, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 24,
                right: 24,
                child: IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageArea = CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) =>
          const Center(child: Icon(Icons.broken_image, size: 64)),
      imageBuilder: (context, imageProvider) {
        return GestureDetector(
          onTap: () => _openZoomViewer(context, imageProvider),
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: SizedBox.expand(
              child: Image(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );

    if (height != null) {
      return SizedBox(height: height, width: double.infinity, child: imageArea);
    }

    return SizedBox(width: double.infinity, child: imageArea);
  }
}
