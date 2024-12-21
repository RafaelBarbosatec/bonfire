import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/sprite_animation_render.dart';

class ControlledUpdateAnimation {
  bool _alreadyUpdate = false;
  SpriteAnimationRender? animation;
  AssetsLoader? _loader;

  ControlledUpdateAnimation(Future<SpriteAnimation> animation, Vector2 size) {
    _loader = AssetsLoader();
    _loader?.add(
      AssetToLoad<SpriteAnimation>(
        animation,
        (value) {
          this.animation = SpriteAnimationRender(
            animation: value,
            size: size,
          );
        },
      ),
    );
  }

  ControlledUpdateAnimation.fromSpriteAnimation(SpriteAnimation animation) {
    this.animation = SpriteAnimationRender(
      animation: animation,
    );
  }

  void render(Canvas canvas, {Vector2? size, Paint? overridePaint}) {
    animation?.render(canvas, size: size, overridePaint: overridePaint);
    _alreadyUpdate = false;
  }

  void update(double dt, Vector2 size) {
    if (!_alreadyUpdate) {
      _alreadyUpdate = true;
      animation?.update(dt);
      animation?.size = size;
    }
  }

  Future<void> onLoad() async {
    await _loader?.load();
    _loader = null;
  }
}
