import 'dart:async';

import 'package:bonfire/bonfire.dart';

export 'direction_animation_api.dart';

/// Mixin responsible for adding animations to movements
mixin WithDirectionAnimation on Movement {
  late final DirectionAnimationApi directionAnimation = DirectionAnimationApi(
    this,
  );

  SimpleDirectionAnimation? get animation => directionAnimation.animation;
  set animation(SimpleDirectionAnimation? value) =>
      directionAnimation.animation = value;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    directionAnimation.render(canvas, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    directionAnimation.updateAnimation();
    directionAnimation.update(dt);
  }

  @override
  void idle() {
    super.idle();
    directionAnimation.playIdleAnimation();
  }

  @override
  Future<void> onLoad() async {
    await directionAnimation.onLoad(gameRef);
    return super.onLoad();
  }

  @override
  void onMount() {
    super.onMount();
    directionAnimation.playIdleAnimation();
  }
}
