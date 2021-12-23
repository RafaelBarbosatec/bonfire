import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';

class AnimatedFollowerObject extends FollowerObject {
  final bool loopAnimation;
  final _loader = AssetsLoader();
  SpriteAnimation? animation;

  AnimatedFollowerObject({
    required Future<SpriteAnimation> animation,
    required GameComponent target,
    Vector2Rect? positionFromTarget,
    this.loopAnimation = false,
  }) : super(target, positionFromTarget) {
    _loader.add(AssetToLoad(animation, (value) => this.animation = value));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    animation?.getSprite().renderFromVector2Rect(
          canvas,
          this.position,
          opacity: opacity,
        );
  }

  @override
  void update(double dt) {
    animation?.update(dt);
    super.update(dt);
    if (!loopAnimation) {
      if (animation?.isLastFrame == true) {
        removeFromParent();
      }
    }
  }

  @override
  Future<void> onLoad() {
    super.onLoad();
    return _loader.load();
  }
}
