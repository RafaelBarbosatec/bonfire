import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/foundation.dart';

extension ImageExtension on Image {
  SpriteAnimation getAnimation({
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
      spriteList.add(Sprite(
        this,
        srcPosition: Vector2(
          (startDx + (i * width)).toDouble(),
          startDy.toDouble(),
        ),
        srcSize: Vector2(
          width,
          height,
        ),
      ));
    }
    return SpriteAnimation.spriteList(
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
    return Sprite(
      this,
      srcPosition: Vector2(x, y),
      srcSize: Vector2(width, height),
    );
  }
}

extension OffSetExt on Offset {
  Offset copyWith({double x, double y}) {
    return Offset(x ?? this.dx, y ?? this.dy);
  }

  Vector2 toVector2() {
    return Vector2(this.dx, this.dy);
  }
}

extension RectExt on Rect {
  Vector2Rect toVector2Rect() {
    return Vector2Rect.fromRect(this);
  }
}

extension SpriteExt on Sprite {
  bool loaded() {
    return this.image != null;
  }

  void renderFromVector2Rect(Canvas canvas, Vector2Rect vector,
      {Paint overridePaint}) {
    if (this.image != null) {
      canvas.drawImageRect(
        this.image,
        this.src,
        vector.rect,
        overridePaint ?? this.paint,
      );
    }
  }
}
