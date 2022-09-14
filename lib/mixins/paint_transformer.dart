import 'package:bonfire/bonfire.dart';
import 'package:flutter/rendering.dart';

mixin RenderTransformer on PositionComponent {
  // /// Rotation angle (in radians) of the component. The component will be
  // /// rotated around its anchor point in the clockwise direction if the
  // /// angle is positive, or counterclockwise if the angle is negative.
  @override
  double angle = 0;

  /// Use to do vertical flip in de render.
  bool isFlipVertical = false;

  /// Use to do horizontal flip in de render.
  bool isFlipHorizontal = false;

  bool get _needTransform => isFlipHorizontal || isFlipVertical || angle != 0;

  void _applyFlipAndRotation(Canvas canvas) {
    canvas.translate(center.x, center.y);
    if (angle != 0) {
      canvas.rotate(angle);
    }
    if (isFlipHorizontal || isFlipVertical) {
      canvas.scale(isFlipHorizontal ? -1 : 1, isFlipVertical ? -1 : 1);
    }
    canvas.translate(-center.x, -center.y);
  }

  @override
  void renderTree(Canvas canvas) {
    if (_needTransform) {
      preRenderBeforeTransformation(canvas);
      canvas.save();
      _applyFlipAndRotation(canvas);
      render(canvas);
      for (var c in children) {
        c.renderTree(canvas);
      }

      // Any debug rendering should be rendered on top of everything
      if (debugMode) {
        renderDebugMode(canvas);
      }

      canvas.restore();
    } else {
      preRenderBeforeTransformation(canvas);
      render(canvas);
      for (var c in children) {
        c.renderTree(canvas);
      }

      // Any debug rendering should be rendered on top of everything
      if (debugMode) {
        renderDebugMode(canvas);
      }
    }
  }

  void preRenderBeforeTransformation(Canvas canvas) {}

  @override
  void renderDebugMode(Canvas canvas) {
    final rect = toRect();
    canvas.drawRect(rect, debugPaint);

    final dx = rect.right;
    final dy = rect.bottom;
    debugTextPaint.render(
      canvas,
      'x:${dx.toStringAsFixed(2)} y:${dy.toStringAsFixed(2)}',
      Vector2(dx - 50, dy),
    );
  }
}
