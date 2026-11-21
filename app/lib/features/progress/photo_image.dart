import 'dart:io';

import 'package:flutter/material.dart';

/// A photo from the app's private folder, cropped to fill. Shows a quiet placeholder if the
/// file can't be read, so one missing file never breaks the screen.
class PhotoImage extends StatelessWidget {
  const PhotoImage(this.file, {super.key, this.fit = BoxFit.cover, this.cacheWidth});
  final File file;
  final BoxFit fit;

  /// Decode at about this many pixels wide; keeps a screen of thumbnails light on memory.
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Image.file(
      file,
      fit: fit,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Center(child: Icon(Icons.image_not_supported_outlined, color: scheme.onSurfaceVariant)),
      ),
    );
  }
}

/// A 3:4 rounded photo tile.
class PhotoTile extends StatelessWidget {
  const PhotoTile(this.file, {super.key, this.onTap});
  final File file;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          child: InkWell(
            onTap: onTap,
            child: Ink.image(
              image: ResizeImage(FileImage(file), width: 600),
              fit: BoxFit.cover,
              onImageError: (_, _) {},
            ),
          ),
        ),
      ),
    );
  }
}
