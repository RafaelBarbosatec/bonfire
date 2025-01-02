// ignore_for_file: must_call_super

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/parallax/camera_parallax.dart';
import 'package:flutter/painting.dart';

class CameraParallaxComponent extends ParallaxComponent with BonfireHasGameRef {
  CameraParallaxComponent({
    super.parallax,
    super.position,
    super.priority,
    super.scale,
    super.size,
    super.key,
    super.anchor,
    super.angle,
  });
  static Future<ParallaxComponent> load(
    Iterable<ParallaxData> dataList, {
    Vector2? baseVelocity,
    Vector2? velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images? images,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
    FilterQuality? filterQuality,
    ComponentKey? key,
  }) async {
    return CameraParallaxComponent(
      parallax: await CameraParallax.load(
        dataList,
        size: size,
        baseVelocity: baseVelocity,
        velocityMultiplierDelta: velocityMultiplierDelta,
        repeat: repeat,
        alignment: alignment,
        fill: fill,
        images: images,
        filterQuality: filterQuality,
      ),
      position: position,
      size: size,
      scale: scale,
      angle: angle,
      anchor: anchor,
      priority: priority,
      key: key,
    );
  }

  Vector2 _camPosition = Vector2.zero();

  @override
  void update(double dt) {
    final campP = gameRef.camera.position;
    if (campP != _camPosition) {
      final velocity = campP - _camPosition;
      _camPosition = campP.clone();
      (parallax! as CameraParallax).moveParallax(velocity, dt);
    }
  }
}
