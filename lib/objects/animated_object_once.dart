import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/objects/animated_object.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:flame/sprite.dart';

class AnimatedObjectOnce extends AnimatedObject with Lighting {
  final VoidCallback? onFinish;
  final VoidCallback? onStartAnimation;
  final double? rotateRadAngle;
  bool _notifyStart = false;

  final _loader = AssetsLoader();

  AnimatedObjectOnce({
    required Vector2 position,
    required Vector2 size,
    Future<SpriteAnimation>? animation,
    this.onFinish,
    this.onStartAnimation,
    this.rotateRadAngle,
    LightingConfig? lightingConfig,
  }) {
    _loader.add(AssetToLoad(animation, (value) {
      this.animation = value..loop = false;
    }));
    setupLighting(lightingConfig);
    this.position = position;
    this.size = size;
    this.angle = rotateRadAngle ?? 0.0;
  }

  @override
  void render(Canvas canvas) {
    // if (rotateRadAngle != null) {
    //   canvas.save();
    //   canvas.translate(center.x, center.y);
    //   canvas.rotate(rotateRadAngle == 0.0 ? 0.0 : rotateRadAngle! + (pi / 2));
    //   canvas.translate(-center.x, -center.y);
    //   super.render(canvas);
    //   canvas.restore();
    // } else {
    //   super.render(canvas);
    // }
    if (animation?.done() == true) {
      onFinish?.call();
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (animation != null && !shouldRemove) {
      if (animation?.currentIndex == 1 && !_notifyStart) {
        _notifyStart = true;
        onStartAnimation?.call();
      }
    }
  }

  @override
  Future<void> onLoad() {
    super.onLoad();
    return _loader.load();
  }
}
