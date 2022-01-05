import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';

class AnimatedFollowerObject extends FollowerObject {
  final bool loopAnimation;
  AssetsLoader? _loader = AssetsLoader();
  SpriteAnimation? animation;

  AnimatedFollowerObject({
    required Future<SpriteAnimation> animation,
    required GameComponent target,
    required Vector2 size,
    Vector2? positionFromTarget,
    this.loopAnimation = false,
  }) : super(target, positionFromTarget, size) {
    _loader?.add(AssetToLoad(animation, (value) => this.animation = value));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    animation?.getSprite().renderWithOpacity(
          canvas,
          this.position,
          this.size,
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
  Future<void> onLoad() async {
    await _loader?.load();
    _loader = null;
    return super.onLoad();
  }
}
