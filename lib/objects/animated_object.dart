import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/animation.dart' as FlameAnimation;

/// This represents a Component for your game in bonfire.
///
/// All components like [Enemy],[Player] and [GameDecoration] extends this.
class AnimatedObject extends GameComponent {
  /// Animation that will be drawn on the screen.
  FlameAnimation.Animation animation;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (animation == null || position == null) return;
    if (animation.loaded()) {
      animation.getSprite().renderRect(canvas, position);
    }
  }

  @override
  void update(double dt) {
    if (animation != null) animation.update(dt);
    super.update(dt);
  }

  @override
  int priority() => PriorityLayer.OBJECTS;
}
