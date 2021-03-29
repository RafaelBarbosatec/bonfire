import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flame/components.dart' hide JoystickMoveDirectional;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Camera with HasGameRef<BonfireGame> {
  static const SPACING_MAP = 20.0;
  Offset position = Offset.zero;
  double zoom;
  Offset _lastTargetOffset = Offset.zero;
  GameComponent target;
  final Size sizeMovementWindow;
  final bool moveOnlyMapArea;

  Camera({
    this.zoom = 1.0,
    this.target,
    this.moveOnlyMapArea = false,
    this.sizeMovementWindow = const Size(50, 50),
  });

  Rect get cameraRect => Rect.fromCenter(
        center: Offset(position.dx, position.dy),
        width: gameRef.size.x * _zoomFactor(),
        height: gameRef.size.y * _zoomFactor(),
      );

  Rect get cameraRectWithSpacing => Rect.fromCenter(
        center: Offset(cameraRect.center.dx, cameraRect.center.dy),
        width: cameraRect.width + SPACING_MAP,
        height: cameraRect.height + SPACING_MAP,
      );

  void moveTop(double displacement) {
    position = position.translate(0, displacement * -1);
  }

  void moveRight(double displacement) {
    position = position.translate(displacement, 0);
  }

  void moveBottom(double displacement) {
    position = position.translate(0, displacement);
  }

  void moveLeft(double displacement) {
    position = position.translate(displacement * -1, 0);
  }

  void moveCamera(double displacement, JoystickMoveDirectional directional) {
    switch (directional) {
      case JoystickMoveDirectional.MOVE_UP:
        moveTop(displacement);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        moveRight(displacement);
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        moveBottom(displacement);
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        moveLeft(displacement);
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        break;
      case JoystickMoveDirectional.IDLE:
        break;
    }
  }

  void moveToPositionAnimated(
    Offset position, {
    double zoom = 1,
    VoidCallback finish,
    Duration duration,
    Curve curve = Curves.decelerate,
  }) {
    if (gameRef?.size == null) return;
    if (zoom <= 0.0) return;
    target = null;

    double diffX = this.position.dx - position.dx;
    double diffY = this.position.dy - position.dy;
    double originX = this.position.dx;
    double originY = this.position.dy;

    double diffZoom = this.zoom - zoom;
    double initialZoom = this.zoom;

    gameRef
        .getValueGenerator(
          duration ?? Duration(seconds: 1),
          onChange: (value) {
            this.position =
                this.position.copyWith(x: originX - (diffX * value));
            this.position =
                this.position.copyWith(y: originY - (diffY * value));
            this.zoom = initialZoom - (diffZoom * value);
          },
          onFinish: () => finish?.call(),
          curve: curve,
        )
        .start();
  }

  void moveToTargetAnimated(
    GameComponent target, {
    double zoom = 1,
    VoidCallback finish,
    Duration duration,
    Curve curve = Curves.decelerate,
  }) {
    if (gameRef?.size == null) return;
    if (zoom <= 0.0) return;
    this.target = null;

    double diffX = this.position.dx - target.position.rect.center.dx;
    double diffY = this.position.dy - target.position.rect.center.dy;
    double originX = this.position.dx;
    double originY = this.position.dy;

    double diffZoom = this.zoom - zoom;
    double initialZoom = this.zoom;

    gameRef.getValueGenerator(
      duration ?? Duration(seconds: 1),
      onChange: (value) {
        this.position = position.copyWith(x: originX - (diffX * value));
        this.position = position.copyWith(y: originY - (diffY * value));
        this.zoom = initialZoom - (diffZoom * value);
      },
      onFinish: () {
        this.target = target;
        finish?.call();
      },
      curve: curve,
    ).start();
  }

  void moveToPosition(Offset position) {
    if (gameRef?.size == null) return;
    target = null;
    this.position = position;
  }

  void moveToPlayer() {
    this.target = gameRef.player;
  }

  void moveToTarget(GameComponent target) {
    this.target = target;
  }

  void moveToPlayerAnimated({
    Duration duration,
    VoidCallback finish,
    double zoom = 1,
    Curve curve = Curves.decelerate,
  }) {
    if (gameRef.player == null) return;
    moveToTargetAnimated(
      gameRef.player,
      zoom: zoom,
      finish: finish,
      duration: duration,
      curve: curve,
    );
  }

  void _followTarget({double horizontal = 50, double vertical = 50}) {
    if (target == null || gameRef?.size == null) return;
    if (_lastTargetOffset == target.position.rect.center) return;
    _lastTargetOffset = target.position.rect.center;
    final screenCenter = Offset(
      gameRef.size.x / 2,
      gameRef.size.y / 2,
    );
    final positionTarget = worldPositionToScreen(target.position.rect.center);

    final horizontalDistance = screenCenter.dx - positionTarget.dx;
    final verticalDistance = screenCenter.dy - positionTarget.dy;

    if (horizontalDistance.abs() > horizontal) {
      this.position = this.position.translate(
          horizontalDistance > 0
              ? horizontal - horizontalDistance
              : -horizontalDistance - horizontal,
          0);
    }
    if (verticalDistance.abs() > vertical) {
      this.position = this.position.translate(
          0,
          verticalDistance > 0
              ? vertical - verticalDistance
              : -verticalDistance - vertical);
    }

    if (moveOnlyMapArea) {
      _keepInMapArea();
    }
  }

  void animateZoom({
    double zoom,
    Duration duration,
    VoidCallback finish,
    Curve curve = Curves.decelerate,
  }) {
    if (gameRef?.size == null) return;
    if (zoom <= 0.0) return;

    double diffZoom = this.zoom - (zoom);
    double initialZoom = this.zoom;

    gameRef.getValueGenerator(
      duration ?? Duration(seconds: 1),
      onChange: (value) {
        this.zoom = initialZoom - (diffZoom * value);
      },
      onFinish: finish,
      curve: curve,
    )..start();
  }

  bool isComponentOnCamera(GameComponent c) {
    if (gameRef?.size == null || c.position == null) return false;

    return cameraRectWithSpacing.overlaps(c.position.rect);
  }

  bool isRectOnCamera(Rect c) {
    if (gameRef?.size == null || c == null) return false;

    return cameraRectWithSpacing.overlaps(c);
  }

  Offset worldPositionToScreen(Offset position) {
    return position.translate(
      this.cameraRect.left * -1,
      this.cameraRect.top * -1,
    );
  }

  Offset screenPositionToWorld(Offset position) {
    double diffX = position.dx - gameRef.size.x / 2;
    double diffY = position.dy - gameRef.size.y / 2;
    return Offset(
      this.cameraRect.center.dx + (diffX / zoom),
      this.cameraRect.center.dy + (diffY / zoom),
    );
  }

  void update() {
    _followTarget(
      vertical: sizeMovementWindow.height,
      horizontal: sizeMovementWindow.width,
    );
  }

  void _keepInMapArea() {
    final startPosition = gameRef.map.mapStartPosition;
    final sizeMap = gameRef.map.mapSize;
    final limitX = (startPosition.x + gameRef.size.x / 2);
    final limitY = (startPosition.y + gameRef.size.y / 2);
    final limitMaxX = (sizeMap.width - gameRef.size.x / 2);
    final limitMaxY = (sizeMap.height - gameRef.size.y / 2);

    if (this.position.dx > limitMaxX) {
      this.position = Offset(limitMaxX, position.dy);
    }
    if (this.position.dy > limitMaxY) {
      this.position = Offset(position.dx, limitMaxY);
    }

    if (this.position.dx < limitX) {
      this.position = Offset(limitMaxX, position.dy);
    }
    if (this.position.dy < limitY) {
      this.position = Offset(position.dx, limitMaxY);
    }
  }

  double _zoomFactor() {
    if (zoom > 1) return 1;
    return 1 / zoom;
  }
}
