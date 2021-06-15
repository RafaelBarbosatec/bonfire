import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/vector2rect.dart';

extension ImageExtension on Image {
  SpriteAnimation getAnimation({
    required double width,
    required double height,
    required double count,
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
    required double x,
    required double y,
    required double width,
    required double height,
  }) {
    return Sprite(
      this,
      srcPosition: Vector2(x, y),
      srcSize: Vector2(width, height),
    );
  }

  /// Do merge image. Overlaying the images
  Future<Image> overlap(Image other) {
    PictureRecorder recorder = PictureRecorder();
    final paint = Paint();
    Canvas canvas = Canvas(recorder);
    final totalWidth = max(this.width, other.width);
    final totalHeight = max(this.height, other.height);
    canvas.drawImage(this, Offset.zero, paint);
    canvas.drawImage(other, Offset.zero, paint);
    return recorder.endRecording().toImage(totalWidth, totalHeight);
  }

  /// Do merge image list. Overlaying the images
  Future<Image> overlapList(List<Image> others) {
    PictureRecorder recorder = PictureRecorder();
    final paint = Paint();
    Canvas canvas = Canvas(recorder);
    int totalWidth = this.width;
    int totalHeight = this.height;
    canvas.drawImage(this, Offset.zero, paint);
    others.forEach((i) {
      totalWidth = max(totalWidth, i.width);
      totalHeight = max(totalHeight, i.height);
      canvas.drawImage(i, Offset.zero, paint);
    });
    return recorder.endRecording().toImage(totalWidth, totalHeight);
  }
}

extension OffSetExt on Offset {
  Offset copyWith({double? x, double? y}) {
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
  void renderFromVector2Rect(
    Canvas canvas,
    Vector2Rect vector, {
    Paint? overridePaint,
  }) {
    this.render(canvas, position: vector.position, size: vector.size);
  }
}

extension NullableExt<T> on T? {
  FutureOr<void> let(FutureOr<void> Function(T i) call) => call(this!);
}

extension GameComponentExt on GameComponent {
  Direction? directionThePlayerIsIn() {
    Player? player = this.gameRef.player;
    if (player == null) return null;
    var diffX = position.center.dx - player.position.center.dx;
    var diffPositiveX = diffX < 0 ? diffX *= -1 : diffX;
    var diffY = position.center.dy - player.position.center.dy;
    var diffPositiveY = diffY < 0 ? diffY *= -1 : diffY;

    if (diffPositiveX > diffPositiveY) {
      if (player.position.center.dx > position.center.dx) {
        return Direction.right;
      } else if (player.position.center.dx < position.center.dx) {
        return Direction.left;
      }
    } else {
      if (player.position.center.dy > position.center.dy) {
        return Direction.down;
      } else if (player.position.center.dy < position.center.dy) {
        return Direction.up;
      }
    }

    return Direction.left;
  }
}

extension Vector2Ext on Vector2 {
  Vector2 translate(double x, double y) {
    return Vector2(this.x + x, this.y + y);
  }
}

extension ObjectExt<T> on T {
  Future<T> asFuture() {
    return Future.value(this);
  }
}
