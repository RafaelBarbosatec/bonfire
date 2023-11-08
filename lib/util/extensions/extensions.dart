import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart' as widget;

export 'ally/ally_extensions.dart';
export 'enemy/enemy_extensions.dart';
export 'enemy/rotation_enemy_extensions.dart';
export 'game_component_extensions.dart';
export 'joystick_extensions.dart';
export 'movement_extensions.dart';
export 'npc/npc_extensions.dart';
export 'player/player_extensions.dart';
export 'player/rotation_player_extensions.dart';

typedef BoolCallback = bool Function();

extension BonfireImageExtension on Image {
  SpriteAnimation getAnimation({
    required Vector2 size,
    required int amount,
    Vector2? position,
    double stepTime = 0.1,
    bool loop = true,
  }) {
    return SpriteAnimation.fromFrameData(
      this,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: size,
        loop: loop,
        texturePosition: position,
      ),
    );
  }

  Sprite getSprite({
    Vector2? position,
    Vector2? size,
  }) {
    return Sprite(
      this,
      srcPosition: position,
      srcSize: size,
    );
  }

  /// Do merge image. Overlaying the images
  /// @deprecated Use [ImageComposition]
  Future<Image> overlap(Image other) {
    PictureRecorder recorder = PictureRecorder();
    final paint = Paint();
    Canvas canvas = Canvas(recorder);
    final totalWidth = max(width, other.width);
    final totalHeight = max(height, other.height);
    canvas.drawImage(this, Offset.zero, paint);
    canvas.drawImage(other, Offset.zero, paint);
    return recorder.endRecording().toImage(totalWidth, totalHeight);
  }

  /// Do merge image list. Overlaying the images
  Future<Image> overlapList(List<Image> others) {
    PictureRecorder recorder = PictureRecorder();
    final paint = Paint();
    Canvas canvas = Canvas(recorder);
    int totalWidth = width;
    int totalHeight = height;
    canvas.drawImage(this, Offset.zero, paint);
    for (var i in others) {
      totalWidth = max(totalWidth, i.width);
      totalHeight = max(totalHeight, i.height);
      canvas.drawImage(i, Offset.zero, paint);
    }
    return recorder.endRecording().toImage(totalWidth, totalHeight);
  }
}

extension OffSetExt on Offset {
  Offset copyWith({double? x, double? y}) {
    return Offset(x ?? dx, y ?? dy);
  }

  Offset rotate(double angle, Offset center) {
    return BonfireUtil.rotatePoint(this, angle, center);
  }
}

extension RectExt on Rect {
  Vector2 get positionVector2 => Vector2(left, top);
  Vector2 get sizeVector2 => Vector2(width, height);

  Rectangle getRectangleByTileSize(double tileSize) {
    final left = (this.left / tileSize).floorToDouble();
    final top = (this.top / tileSize).floorToDouble();
    final width = (this.width / tileSize).ceilToDouble();
    final height = (this.height / tileSize).ceilToDouble();

    return Rectangle(
      left,
      top,
      width,
      height,
    );
  }

  bool overlapComponent(PositionComponent c) {
    double left = c.position.x;
    double top = c.position.y;
    double right = c.position.x + c.size.x;
    double bottom = c.position.y + c.size.y;
    if (this.right <= left || right <= this.left) {
      return false;
    }
    if (this.bottom <= top || bottom <= this.top) {
      return false;
    }
    return true;
  }

  /// Returns a new rectangle with edges moved outwards by the given delta.
  Rect inflatexy(double deltaX, double deltaY) {
    return Rect.fromLTRB(
        left - deltaX, top - deltaY, right + deltaX, bottom + deltaY);
  }

  /// Returns a new rectangle with edges moved inwards by the given delta.
  Rect deflatexy(double deltaX, double deltaY) => inflatexy(-deltaX, -deltaY);

  Vector2 get centerVector2 => Vector2(left + width / 2.0, top + height / 2.0);
}

extension SpriteFutureExt on Future<Sprite> {
  Future<SpriteAnimation> toAnimation() async {
    var sprite = await this;
    return SpriteAnimation.spriteList([sprite], stepTime: 1);
  }
}

extension NullableExt<T> on T? {
  FutureOr<void> let(FutureOr<void> Function(T i) call) {
    if (this != null) {
      call(this as T);
    }
  }
}

extension Vector2Ext on Vector2 {
  Vector2 copyWith({double? x, double? y}) {
    return Vector2(x ?? this.x, y ?? this.y);
  }

  double maxValue() {
    return max(x, y);
  }
}

extension ObjectExt<T> on T {
  Future<T> asFuture() {
    return Future.value(this);
  }
}

extension FutureSpriteAnimationExt on FutureOr<SpriteAnimation> {
  widget.Widget asWidget({
    widget.Key? key,
    bool playing = true,
    Anchor anchor = Anchor.topLeft,
  }) {
    if (this is Future) {
      return widget.FutureBuilder<SpriteAnimation>(
        key: key,
        future: this as Future<SpriteAnimation>,
        builder: (context, data) {
          if (!data.hasData) return const widget.SizedBox.shrink();
          return widget.Container(
            constraints: widget.BoxConstraints(
              minWidth: data.data!.frames.first.sprite.src.width,
              minHeight: data.data!.frames.first.sprite.src.height,
            ),
            child: SpriteAnimationWidget(
              animation: data.data!,
              animationTicker: data.data!.createTicker(),
              playing: playing,
              anchor: anchor,
            ),
          );
        },
      );
    }

    return widget.Container(
      key: key,
      constraints: widget.BoxConstraints(
        minWidth: (this as SpriteAnimation).frames.first.sprite.src.width,
        minHeight: (this as SpriteAnimation).frames.first.sprite.src.height,
      ),
      child: SpriteAnimationWidget(
        animation: this as SpriteAnimation,
        animationTicker: (this as SpriteAnimation).createTicker(),
        playing: playing,
        anchor: anchor,
      ),
    );
  }
}

extension FutureSpriteExt on FutureOr<Sprite> {
  widget.Widget asWidget({
    widget.Key? key,
    Anchor anchor = Anchor.topLeft,
    double angle = 0,
    Vector2? srcPosition,
    Vector2? srcSize,
  }) {
    if (this is Future) {
      return widget.FutureBuilder<Sprite>(
        key: key,
        future: this as Future<Sprite>,
        builder: (context, data) {
          if (!data.hasData) return const widget.SizedBox.shrink();
          return widget.Container(
            constraints: widget.BoxConstraints(
              minWidth: data.data!.src.width,
              minHeight: data.data!.src.height,
            ),
            child: SpriteWidget(
              sprite: data.data!,
              anchor: anchor,
              angle: angle,
              srcPosition: srcPosition,
              srcSize: srcSize,
            ),
          );
        },
      );
    }

    return widget.Container(
      key: key,
      constraints: widget.BoxConstraints(
        minWidth: (this as Sprite).src.width,
        minHeight: (this as Sprite).src.height,
      ),
      child: SpriteWidget(
        sprite: this as Sprite,
        anchor: anchor,
        angle: angle,
        srcPosition: srcPosition,
        srcSize: srcSize,
      ),
    );
  }
}

extension ComponentExt on GameComponent {
  bool get isHud {
    if (hasGameRef) {
      bool thisIs = gameRef.camera.viewport.contains(this);
      bool parentIs = false;
      if (parent != null) {
        parentIs = gameRef.camera.viewport.contains(parent!);
      }
      return parentIs || thisIs;
    }
    return false;
  }
}

extension DirectionExt on Direction {
  double toRadians() {
    return BonfireUtil.getAngleFromDirection(this);
  }

  Vector2 toVector2() {
    switch (this) {
      case Direction.left:
        return Vector2(-1, 0);
      case Direction.right:
        return Vector2(1, 0);
      case Direction.up:
        return Vector2(0, -1);
      case Direction.down:
        return Vector2(0, 1);
      case Direction.upLeft:
        return Vector2(-1, -1);
      case Direction.upRight:
        return Vector2(1, -1);
      case Direction.downLeft:
        return Vector2(-1, 1);
      case Direction.downRight:
        return Vector2(1, 1);
    }
  }
}

extension PositionComponentExt on PositionComponent {
  void applyBleedingPixel({
    required Vector2 position,
    required Vector2 size,
    double factor = 0.04,
    double offsetX = 0,
    double offsetY = 0,
    bool calculatePosition = false,
  }) {
    double bleedingPixel = max(size.x, size.y) * factor;

    bleedingPixel = bleedingPixel > 2 ? 2 : bleedingPixel;
    bleedingPixel = bleedingPixel < 0.6 ? 0.6 : bleedingPixel;
    bool xIsEven = position.x % 2 == 0;
    bool yIsEven = position.y % 2 == 0;
    Vector2 baseP = position;
    if (calculatePosition) {
      baseP = Vector2(position.x * size.x, position.y * size.y);
    }
    this.position = Vector2(
      baseP.x - (xIsEven ? (bleedingPixel / 2) : 0) + offsetX,
      baseP.y - (yIsEven ? (bleedingPixel / 2) : 0) + offsetY,
    );
    this.size = Vector2(
      size.x + (xIsEven ? bleedingPixel : 0),
      size.y + (yIsEven ? bleedingPixel : 0),
    );
  }
}

extension ShapeHitbocExt on ShapeHitbox {
  ShapeHitbox clone() {
    if (e is RectangleHitbox) {
      RectangleHitbox rect = e as RectangleHitbox;
      return RectangleHitbox(
        anchor: rect.anchor,
        angle: rect.angle,
        isSolid: rect.isSolid,
        position: rect.position,
        priority: rect.priority,
        size: rect.size,
      );
    }

    if (e is CircleHitbox) {
      CircleHitbox circle = e as CircleHitbox;
      return CircleHitbox(
        anchor: circle.anchor,
        angle: circle.angle,
        isSolid: circle.isSolid,
        position: circle.position,
        radius: circle.radius,
      );
    }

    if (e is PolygonHitbox) {
      PolygonHitbox poly = e as PolygonHitbox;
      return PolygonHitbox(
        poly.vertices,
        anchor: poly.anchor,
        angle: poly.angle,
        isSolid: poly.isSolid,
        position: poly.position,
      );
    }
    return this;
  }
}

extension MouseButtonExt on MouseButton {
  int get id {
    switch (this) {
      case MouseButton.left:
        return 1;
      case MouseButton.right:
        return 2;
      case MouseButton.middle:
        return 4;
      case MouseButton.unknow:
        return 0;
    }
  }
}
