import 'package:bonfire/bonfire.dart';
import 'package:flame/game.dart';
import 'package:flutter/rendering.dart';

mixin RenderTransformer on PositionComponent {
  static final Vector2 _initialScale = Vector2.all(1);
  // /// Rotation angle (in radians) of the component. The component will be
  // /// rotated around its anchor point in the clockwise direction if the
  // /// angle is positive, or counterclockwise if the angle is negative.
  @override
  double angle = 0;

  Vector2 _scale = _initialScale;

  @override
  NotifyingVector2 get scale => NotifyingVector2.copy(_scale);

  @override
  set scale(Vector2 scale) => _scale = scale;

  /// Use to do vertical flip in de render.
  bool isFlipVertically = false;

  /// Use to do horizontal flip in de render.
  bool isFlipHorizontally = false;

  @override
  void flipHorizontally() {
    isFlipHorizontally = !isFlipHorizontally;
    super.flipHorizontally();
  }

  @override
  void flipVertically() {
    isFlipVertically = !isFlipVertically;
    super.flipVertically();
  }

  @override
  void flipHorizontallyAroundCenter() {
    flipHorizontally();
  }

  @override
  void flipVerticallyAroundCenter() {
    flipVertically();
  }

  bool _needCenterTranslate = false;

  @override
  void update(double dt) {
    _needCenterTranslate = isFlipHorizontally ||
        isFlipVertically ||
        angle != 0 ||
        scale != _initialScale;
    super.update(dt);
  }

  @override
  void renderTree(Canvas canvas) {
    _applyTransform(canvas);
  }

  void _applyTransform(Canvas canvas) {
    renderBeforeTransformation(canvas);

    if (_needCenterTranslate) {
      canvas.save();
      canvas.translate(center.x, center.y);
      canvas.rotate(angle);
      canvas.scale(isFlipHorizontally ? -scale.x : scale.x,
          isFlipVertically ? -scale.y : scale.y);
      canvas.translate(-center.x, -center.y);
    }

    render(canvas);
    for (var c in children) {
      c.renderTree(canvas);
    }

    // Any debug rendering should be rendered on top of everything
    if (debugMode) {
      renderDebugMode(canvas);
    }

    if (_needCenterTranslate) {
      canvas.restore();
    }
  }

  void renderBeforeTransformation(Canvas canvas) {}

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
