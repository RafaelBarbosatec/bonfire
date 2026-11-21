import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart' show rootBundle;

/// A sprite-stacked prop.
///
/// The asset is a **horizontal strip of cross-sections**, ground slice first
/// (left). Slice `0` is the bottom of the object and the last slice is the top.
/// Each slice has the same size, so a strip of `N` slices is
/// `(N * sliceWidth) x sliceHeight` pixels.
///
/// Rendering is done at runtime: every slice is drawn rotated by [yaw],
/// vertically squashed by the [pitch] and lifted one [spacing] step, from the
/// ground up. That is the classic sprite-stacking trick and costs one
/// `drawImageRect` per slice.
class SpriteStack {
  SpriteStack._(this.image, this.sliceCount)
      : sliceWidth = image.width ~/ sliceCount,
        sliceHeight = image.height;

  /// Builds a stack from an already decoded strip image.
  ///
  /// Throws [ArgumentError] when [sliceCount] is not positive or when the image
  /// width is not divisible by it.
  factory SpriteStack.fromImage(Image image, {required int sliceCount}) {
    if (sliceCount <= 0) {
      throw ArgumentError.value(
          sliceCount, 'sliceCount', 'must be greater than 0');
    }
    if (image.width % sliceCount != 0) {
      throw ArgumentError(
        'Image width ${image.width} is not divisible by sliceCount $sliceCount',
      );
    }
    return SpriteStack._(image, sliceCount);
  }

  /// Loads and decodes a strip from a Flutter asset.
  static Future<SpriteStack> load(
    String assetPath, {
    required int sliceCount,
  }) async {
    final data = await rootBundle.load(assetPath);
    return decode(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      sliceCount: sliceCount,
    );
  }

  /// Decodes a strip from raw PNG/WebP/GIF bytes.
  static Future<SpriteStack> decode(
    Uint8List bytes, {
    required int sliceCount,
  }) async {
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return SpriteStack.fromImage(frame.image, sliceCount: sliceCount);
  }

  /// The strip: slices side by side, ground slice on the left.
  final Image image;

  /// How many cross-sections the strip contains.
  final int sliceCount;

  /// Width of a single slice, in source pixels.
  final int sliceWidth;

  /// Height of a single slice, in source pixels.
  final int sliceHeight;

  /// Default pitch: a slightly elevated camera, in radians (~31°).
  static const double defaultPitch = 0.55;

  /// Size of one slice in source pixels.
  Size get sliceSize => Size(sliceWidth.toDouble(), sliceHeight.toDouble());

  /// Converts a [pitch] angle into the vertical squash applied to each slice.
  ///
  /// `0` looks at the object edge-on and `pi / 2` looks straight down. The
  /// result is clamped to `0.08..1` so the stack never collapses completely.
  static double squashFor(double pitch) {
    final clamped = pitch.clamp(0.0, math.pi / 2).toDouble();
    return math.sin(clamped).clamp(0.08, 1.0).toDouble();
  }

  /// Height of the rendered stack, in source pixels.
  double heightFor({double pitch = defaultPitch, double spacing = 1}) =>
      sliceHeight * squashFor(pitch) + (sliceCount - 1) * spacing;

  /// Draws the stack with its **bottom-center** at [position].
  ///
  /// [yaw] is the rotation around the vertical axis, in radians.
  /// [pitch] tilts the camera (`0`..`pi / 2`).
  /// [spacing] is the lift between slices, in source pixels.
  /// [scale] scales the whole prop.
  void render(
    Canvas canvas, {
    required Offset position,
    double yaw = 0,
    double pitch = defaultPitch,
    double scale = 1,
    double spacing = 1,
    Paint? paint,
  }) {
    final squash = squashFor(pitch);
    final effectivePaint = paint ??
        (Paint()
          ..filterQuality = FilterQuality.none
          ..isAntiAlias = false);

    final sourceWidth = sliceWidth.toDouble();
    final sourceHeight = sliceHeight.toDouble();
    final destination = Rect.fromCenter(
      center: Offset.zero,
      width: sourceWidth,
      height: sourceHeight,
    );

    // Center of the ground slice, so its bottom edge sits on `position`.
    final groundCenterY = position.dy - sourceHeight * squash * scale / 2;

    for (var slice = 0; slice < sliceCount; slice++) {
      canvas.save();
      canvas.translate(position.dx, groundCenterY - slice * spacing * scale);
      canvas.scale(scale, scale * squash);
      canvas.rotate(yaw);
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(slice * sourceWidth, 0, sourceWidth, sourceHeight),
        destination,
        effectivePaint,
      );
      canvas.restore();
    }
  }

  /// Releases the decoded image. Do not use the stack afterwards.
  void dispose() => image.dispose();
}
