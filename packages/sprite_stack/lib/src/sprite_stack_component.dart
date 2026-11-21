import 'dart:ui';

import 'package:flame/components.dart';

import 'sprite_stack.dart';

/// Flame/Bonfire component that renders a [SpriteStack].
///
/// The component keeps its own [size] (slice width x rendered height) so hit
/// boxes, selection and `priority`-based Y sorting work as usual. [yaw] spins
/// the prop in place; it does not touch the component's own [angle].
class SpriteStackComponent extends PositionComponent {
  SpriteStackComponent({
    required this.stack,
    this.yaw = 0,
    this.pitch = SpriteStack.defaultPitch,
    this.stackScale = 1,
    this.spacing = 1,
    super.position,
    super.priority,
  }) : super(
          anchor: Anchor.topLeft,
          size: Vector2(
            stack.sliceWidth * stackScale,
            stack.heightFor(pitch: pitch, spacing: spacing) * stackScale,
          ),
        );

  final SpriteStack stack;

  /// Rotation around the vertical axis, in radians.
  double yaw;

  /// Camera tilt, `0` (edge-on) to `pi / 2` (top-down).
  double pitch;

  /// Uniform scale applied when drawing.
  double stackScale;

  /// Lift between slices, in source pixels.
  double spacing;

  @override
  void render(Canvas canvas) {
    stack.render(
      canvas,
      position: Offset(size.x / 2, size.y),
      yaw: yaw,
      pitch: pitch,
      scale: stackScale,
      spacing: spacing,
    );
  }

  /// Recomputes [size] after changing [pitch], [spacing] or [stackScale].
  void updateBounds() {
    size = Vector2(
      stack.sliceWidth * stackScale,
      stack.heightFor(pitch: pitch, spacing: spacing) * stackScale,
    );
  }
}
