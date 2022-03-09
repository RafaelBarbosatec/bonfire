import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions/extensions.dart';
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
    if (this.isVisible) {
      sprite?.renderWithOpacity(
        canvas,
        position,
        size,
        opacity: opacity,
      );
    }
  }
}
