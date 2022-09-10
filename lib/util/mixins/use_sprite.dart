import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:flame/sprite.dart';

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

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (isVisible) {
      sprite?.render(
        canvas,
        position: position,
        size: size,
        overridePaint: paint,
      );
    }
  }
}
