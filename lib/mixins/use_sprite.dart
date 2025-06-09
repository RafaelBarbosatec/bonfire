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
  Vector2? spriteOffset;

  Paint? _strockePaint;
  double _strokeWidth = 0;
  Vector2 _strokeSize = Vector2.zero();
  Vector2 _strokePosition = Vector2.zero();

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!isRemoving && isVisible) {
      if (_strockePaint != null) {
        sprite?.render(
          canvas,
          size: _strokeSize,
          position: _strokePosition + (spriteOffset ?? Vector2.zero()),
          overridePaint: _strockePaint,
        );
      }
      sprite?.render(
        canvas,
        position: spriteOffset,
        size: size,
        overridePaint: paint,
      );
    }
  }

  void showSpriteStroke(Color color, double width, {Vector2? offset}) {
    if (_strockePaint != null &&
        _strokeWidth == width &&
        _strockePaint?.color == color) {
      return;
    }
    _strokeWidth = width;
    _strokePosition = Vector2.all(-_strokeWidth);
    if (offset != null) {
      _strokePosition += offset;
    }
    _strokeSize = Vector2(
      size.x + _strokeWidth * 2,
      size.y + _strokeWidth * 2,
    );
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
