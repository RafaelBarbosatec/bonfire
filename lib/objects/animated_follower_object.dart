import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/objects/follower_object.dart';
import 'package:bonfire/util/vector2rect.dart';

class AnimatedFollowerObject extends FollowerObject {
  final bool loopAnimation;
  SpriteAnimation animation;

  AnimatedFollowerObject({
    this.animation,
    GameComponent target,
    Vector2Rect positionFromTarget,
    this.loopAnimation = false,
  }) : super(target, positionFromTarget);

  AnimatedFollowerObject.futureAnimation({
    Future<SpriteAnimation> animation,
    GameComponent target,
    Vector2Rect positionFromTarget,
    this.loopAnimation = false,
  }) : super(target, positionFromTarget) {
    animation.then((value) => this.animation = value);
  }

  @override
  void render(Canvas canvas) {
    if (animation == null || position == null) return;
    animation.getSprite().renderFromVector2Rect(canvas, this.position);
    super.render(canvas);
  }

  @override
  void update(double dt) {
    animation?.update(dt);
    super.update(dt);
    if (!loopAnimation) {
      if (animation?.isLastFrame == true) {
        remove();
      }
    }
  }
}
