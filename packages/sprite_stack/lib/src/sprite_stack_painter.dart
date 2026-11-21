import 'package:flutter/rendering.dart';

import 'sprite_stack.dart';

/// Paints a [SpriteStack] centered horizontally at the bottom of the canvas.
///
/// Handy for plain Flutter screens and for `CustomPaint` overlays.
class SpriteStackPainter extends CustomPainter {
  SpriteStackPainter({
    required this.stack,
    this.yaw = 0,
    this.pitch = SpriteStack.defaultPitch,
    this.scale = 1,
    this.spacing = 1,
    this.offset = Offset.zero,
    this.stackPaint,
  });

  final SpriteStack stack;

  /// Rotation around the vertical axis, in radians.
  final double yaw;

  /// Camera tilt, `0` (edge-on) to `pi / 2` (top-down).
  final double pitch;

  final double scale;

  /// Lift between slices, in source pixels.
  final double spacing;

  /// Optional offset applied on top of the default bottom-center anchor.
  final Offset offset;

  /// Optional paint, e.g. to apply a color filter.
  final Paint? stackPaint;

  @override
  void paint(Canvas canvas, Size size) {
    stack.render(
      canvas,
      position: Offset(size.width / 2, size.height) + offset,
      yaw: yaw,
      pitch: pitch,
      scale: scale,
      spacing: spacing,
      paint: stackPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SpriteStackPainter oldDelegate) =>
      oldDelegate.stack != stack ||
      oldDelegate.yaw != yaw ||
      oldDelegate.pitch != pitch ||
      oldDelegate.scale != scale ||
      oldDelegate.spacing != spacing ||
      oldDelegate.offset != offset ||
      oldDelegate.stackPaint != stackPaint;
}
