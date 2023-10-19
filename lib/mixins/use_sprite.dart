import 'dart:ui';

import 'package:bonfire/bonfire.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 04/02/22
mixin UseSprite on GameComponent {
  Sprite? sprite;

  Paint? _strockePaint;
  double _strokeWidth = 0;
  Vector2 _strokeSize = Vector2.zero();
  Vector2 _strokePosition = Vector2.zero();

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (isVisible && !isRemoving) {
      if (_strockePaint != null) {
        sprite?.render(
          canvas,
          size: _strokeSize,
          position: _strokePosition,
          overridePaint: _strockePaint,
        );
      }
      sprite?.render(
        canvas,
        size: size,
        overridePaint: paint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_strokeSize.isZero()) {
      _strokeSize = Vector2(
        size.x + _strokeWidth * 2,
        size.y + _strokeWidth * 2,
      );
    }
  }

  void showSpriteStroke(Color color, double width) {
    if (_strockePaint != null &&
        _strokeWidth == width &&
        _strockePaint?.color == color) {
      return;
    }
    _strokeWidth = width;
    _strokePosition = Vector2.all(-_strokeWidth);
    _strokeSize = Vector2.zero();
    _strockePaint = Paint()
      ..color = color
      ..colorFilter = ColorFilter.mode(
        color,
        BlendMode.srcATop,
      );
  }

  void hideSpriteStroke() {
    _strockePaint = null;
  }
}
