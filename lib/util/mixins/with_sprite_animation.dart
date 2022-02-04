import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/components.dart';

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
mixin WithSpriteAnimation on GameComponent {
  /// Animation that will be drawn on the screen.
  SpriteAnimation? animation;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (this.isVisible) {
      animation?.getSprite().renderWithOpacity(
            canvas,
            this.position,
            this.size,
            opacity: opacity,
          );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (this.isVisible) {
      animation?.update(dt);
    }
  }
}
