import 'dart:async';
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart' as widget;

export 'ally/ally_extensions.dart';
export 'enemy/enemy_extensions.dart';
export 'enemy/rotation_enemy_extensions.dart';
export 'game_component_extensions.dart';
export 'image_extensions.dart';
export 'joystick_extensions.dart';
export 'movement_extensions.dart';
export 'npc/npc_extensions.dart';
export 'player/player_extensions.dart';
export 'player/rotation_player_extensions.dart';

typedef BoolCallback = bool Function();

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
    final maxSize = max(this.width, this.height);
    final left = (this.left / tileSize).floorToDouble();
    final top = (this.top / tileSize).floorToDouble();
    final width = (maxSize / tileSize).ceilToDouble();
    final height = (maxSize / tileSize).ceilToDouble();

    return Rectangle(
      left,
      top,
      width,
      height,
    );
  }

  bool overlapComponent(PositionComponent c) {
    final left = c.position.x;
    final top = c.position.y;
    final right = c.position.x + c.size.x;
    final bottom = c.position.y + c.size.y;
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
      left - deltaX,
      top - deltaY,
      right + deltaX,
      bottom + deltaY,
    );
  }

  /// Returns a new rectangle with edges moved inwards by the given delta.
  Rect deflatexy(double deltaX, double deltaY) => inflatexy(-deltaX, -deltaY);

  Vector2 get centerVector2 => Vector2(left + width / 2.0, top + height / 2.0);
}

extension SpriteFutureExt on Future<Sprite> {
  Future<SpriteAnimation> toAnimation({double stepTime = 1}) async {
    final sprite = await this;
    return SpriteAnimation.spriteList([sprite], stepTime: stepTime);
  }
}

extension NullableExt<T> on T? {
  FutureOr<void> let(FutureOr<void> Function(T i) call) {
    if (this != null) {
      return call(this as T);
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

  Direction toDirection() {
    if (x > 0.5 && y < -0.5) {
      return Direction.upRight;
    }

    if (x < -0.5 && y < -0.5) {
      return Direction.upLeft;
    }

    if (x < -0.5 && y > 0.5) {
      return Direction.downLeft;
    }

    if (x > 0.5 && y > 0.5) {
      return Direction.downRight;
    }

    if (x > 0 && y.abs() < 0.5) {
      return Direction.right;
    } else if (x < 0 && y.abs() < 0.5) {
      return Direction.left;
    }

    if (y > 0) {
      return Direction.down;
    } else if (y < 0) {
      return Direction.up;
    }

    return Direction.left;
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
          if (!data.hasData) {
            return const widget.SizedBox.shrink();
          }
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
  }) {
    if (this is Future) {
      return widget.FutureBuilder<Sprite>(
        key: key,
        future: this as Future<Sprite>,
        builder: (context, data) {
          if (!data.hasData) {
            return const widget.SizedBox.shrink();
          }
          return widget.Container(
            constraints: widget.BoxConstraints(
              minWidth: data.data!.src.width,
              minHeight: data.data!.src.height,
            ),
            child: SpriteWidget(
              sprite: data.data!,
              anchor: anchor,
              angle: angle,
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
      ),
    );
  }
}

extension ComponentExt on GameComponent {
  bool get componentIsHud {
    if (hasGameRef) {
      if (gameRef.camera.viewport.contains(this)) {
        return true;
      }
      if (parent != null) {
        return gameRef.camera.viewport.contains(parent!);
      }
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
    var bleedingPixel = max(size.x, size.y) * factor;

    bleedingPixel = bleedingPixel > 2 ? 2 : bleedingPixel;
    bleedingPixel = bleedingPixel < 0.6 ? 0.6 : bleedingPixel;
    final xIsEven = position.x % 2 == 0;
    final yIsEven = position.y % 2 == 0;
    var baseP = position;
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
      final rect = e as RectangleHitbox;
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
      final circle = e as CircleHitbox;
      return CircleHitbox(
        anchor: circle.anchor,
        angle: circle.angle,
        isSolid: circle.isSolid,
        position: circle.position,
        radius: circle.radius,
      );
    }

    if (e is PolygonHitbox) {
      final poly = e as PolygonHitbox;
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
