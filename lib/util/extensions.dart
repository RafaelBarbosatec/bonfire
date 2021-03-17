import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flutter/foundation.dart';

extension ImageExtension on Image {
  FlameAnimation.Animation getAnimation({
    @required double width,
    @required double height,
    @required double count,
    int startDx = 0,
    int startDy = 0,
    double stepTime = 0.1,
    bool loop = true,
  }) {
    List<Sprite> spriteList = [];
    for (int i = 0; i < count; i++) {
      spriteList.add(Sprite.fromImage(
        this,
        x: (startDx + (i * width)).toDouble(),
        y: startDy.toDouble(),
        width: width,
        height: height,
      ));
    }
    return FlameAnimation.Animation.spriteList(
      spriteList,
      loop: loop,
      stepTime: stepTime,
    );
  }

  Sprite getSprite({
    @required double x,
    @required double y,
    @required double width,
    @required double height,
  }) {
    return Sprite.fromImage(
      this,
      x: x,
      y: y,
      width: width,
      height: height,
    );
  }
}
