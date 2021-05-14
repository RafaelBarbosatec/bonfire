import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/lighting/lighting.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/objects/animated_object.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/sprite.dart';

class AnimatedObjectOnce extends AnimatedObject with Lighting {
  final VoidCallback? onFinish;
  final VoidCallback? onStartAnimation;
  final double? rotateRadAngle;
  bool _notifyStart = false;

  final _loader = AssetsLoader();

  AnimatedObjectOnce({
    required Vector2Rect position,
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
  }

  @override
  void render(Canvas canvas) {
    if (rotateRadAngle != null) {
      canvas.save();
      canvas.translate(position.center.dx, position.center.dy);
      canvas.rotate(rotateRadAngle == 0.0 ? 0.0 : rotateRadAngle! + (pi / 2));
      canvas.translate(-position.center.dx, -position.center.dy);
      super.render(canvas);
      canvas.restore();
    } else {
      super.render(canvas);
    }
    if (animation?.done() == true) {
      onFinish?.call();
      remove();
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
    return _loader.load();
  }
}
