import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flame/components.dart' hide JoystickMoveDirectional;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'camera_config.dart';

class Camera with HasGameRef<BonfireGame> {
  double _spacingMap = -32.0;
  Offset position = Offset.zero;
  Offset _lastTargetOffset = Offset.zero;
  final CameraConfig config;

  Camera(this.config);

  Rect get cameraRect => Rect.fromCenter(
        center: Offset(position.dx, position.dy),
        width: (gameRef.size.x) * _zoomFactor(),
        height: (gameRef.size.y) * _zoomFactor(),
      );

  Rect get cameraRectWithSpacing => Rect.fromCenter(
        center: Offset(cameraRect.center.dx, cameraRect.center.dy),
        width: cameraRect.width + _spacingMap,
        height: cameraRect.height + _spacingMap,
      );

  void moveTop(double displacement) {
    position = position.translate(0, displacement * -1);
  }

  void moveRight(double displacement) {
    position = position.translate(displacement, 0);
  }

  void moveDown(double displacement) {
    position = position.translate(0, displacement);
  }

  void moveUp(double displacement) {
    position = position.translate(displacement * -1, 0);
  }

  void moveToPositionAnimated(
    Offset position, {
    double zoom = 1,
    VoidCallback? finish,
    Duration? duration,
    Curve curve = Curves.decelerate,
  }) {
    if (zoom <= 0.0) return;
    config.target = null;

    double diffX = this.position.dx - position.dx;
    double diffY = this.position.dy - position.dy;
    double originX = this.position.dx;
    double originY = this.position.dy;

    double diffZoom = config.zoom - zoom;
    double initialZoom = config.zoom;

    gameRef
        .getValueGenerator(
          duration ?? Duration(seconds: 1),
          onChange: (value) {
            this.position = this.position.copyWith(
                  x: originX - (diffX * value),
                );
            this.position = this.position.copyWith(
                  y: originY - (diffY * value),
                );
            config.zoom = initialZoom - (diffZoom * value);

            if (config.moveOnlyMapArea) {
              _keepInMapArea();
            }
          },
          onFinish: () => finish?.call(),
          curve: curve,
        )
        .start();
  }

  void moveToTargetAnimated(
    GameComponent target, {
    double zoom = 1,
    VoidCallback? finish,
    Duration? duration,
    Curve curve = Curves.decelerate,
  }) {
    if (zoom <= 0.0) return;
    config.target = null;

    double diffX = this.position.dx - target.position.center.dx;
    double diffY = this.position.dy - target.position.center.dy;
    double originX = this.position.dx;
    double originY = this.position.dy;

    double diffZoom = config.zoom - zoom;
    double initialZoom = config.zoom;

    gameRef.getValueGenerator(
      duration ?? Duration(seconds: 1),
      onChange: (value) {
        this.position = position.copyWith(x: originX - (diffX * value));
        this.position = position.copyWith(y: originY - (diffY * value));
        config.zoom = initialZoom - (diffZoom * value);

        if (config.moveOnlyMapArea) {
          _keepInMapArea();
        }
      },
      onFinish: () {
        config.target = target;
        finish?.call();
      },
      curve: curve,
    ).start();
  }

  void moveToPosition(Offset position) {
    config.target = null;
    this.position = position;
  }

  void moveToPlayer() {
    config.target = gameRef.player;
  }

  void moveToTarget(GameComponent target) {
    config.target = target;
  }

  void moveToPlayerAnimated({
    Duration? duration,
    VoidCallback? finish,
    double zoom = 1,
    Curve curve = Curves.decelerate,
  }) {
    if (gameRef.player == null) return;
    moveToTargetAnimated(
      gameRef.player!,
      zoom: zoom,
      finish: finish,
      duration: duration,
      curve: curve,
    );
  }

  void _followTarget({double horizontal = 50, double vertical = 50}) {
    if (config.target == null) return;
    final centerTarget = _getCenterTarget();
    if (_lastTargetOffset == centerTarget) return;
    _lastTargetOffset = centerTarget;
    final screenCenter = Offset(
      gameRef.size.x / 2,
      gameRef.size.y / 2,
    );
    final positionTarget = worldPositionToScreen(_lastTargetOffset);

    final horizontalDistance = screenCenter.dx - positionTarget.dx;
    final verticalDistance = screenCenter.dy - positionTarget.dy;

    if (horizontalDistance.abs() > horizontal) {
      this.position = this.position.translate(
            horizontalDistance > 0
                ? horizontal - horizontalDistance
                : -horizontalDistance - horizontal,
            0,
          );
    }
    if (verticalDistance.abs() > vertical) {
      this.position = this.position.translate(
            0,
            verticalDistance > 0
                ? vertical - verticalDistance
                : -verticalDistance - vertical,
          );
    }

    if (config.moveOnlyMapArea) {
      _keepInMapArea();
    }
  }

  void animateZoom({
    required double zoom,
    Duration? duration,
    VoidCallback? finish,
    Curve curve = Curves.decelerate,
  }) {
    if (zoom <= 0.0) return;

    double diffZoom = config.zoom - (zoom);
    double initialZoom = config.zoom;

    gameRef.getValueGenerator(
      duration ?? Duration(seconds: 1),
      onChange: (value) {
        config.zoom = initialZoom - (diffZoom * value);
      },
      onFinish: finish,
      curve: curve,
    ).start();
  }

  bool isComponentOnCamera(GameComponent c) {
    return cameraRectWithSpacing.overlaps(c.position.rect);
  }

  bool isRectOnCamera(Rect c) {
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
      this.cameraRect.center.dx + (diffX / config.zoom),
      this.cameraRect.center.dy + (diffY / config.zoom),
    );
  }

  void update() {
    _followTarget(
      vertical: config.sizeMovementWindow.height,
      horizontal: config.sizeMovementWindow.width,
    );
  }

  void updateSpacingVisibleMap(double space) {
    _spacingMap = space;
  }

  void _keepInMapArea() {
    final startPosition = gameRef.map.mapStartPosition;
    final sizeMap = gameRef.map.mapSize;
    if (startPosition == null || sizeMap == null) return;

    double zoomFactor = 1 / config.zoom;

    double gameWidth = (gameRef.size.x * zoomFactor) / 2;
    double gameHeight = (gameRef.size.y * zoomFactor) / 2;

    final limitX = (startPosition.x + gameWidth);
    final limitY = (startPosition.y + gameHeight);
    final limitMaxX = (sizeMap.width - gameWidth);
    final limitMaxY = (sizeMap.height - gameHeight);

    if (this.position.dx > limitMaxX) {
      this.position = Offset(limitMaxX, position.dy);
    }
    if (this.position.dy > limitMaxY) {
      this.position = Offset(position.dx, limitMaxY);
    }

    if (this.position.dx < limitX) {
      this.position = Offset(limitX, position.dy);
    }
    if (this.position.dy < limitY) {
      this.position = Offset(position.dx, limitY);
    }
  }

  double _zoomFactor() {
    if (config.zoom > 1) return 1;
    return 1 / config.zoom;
  }

  Offset _getCenterTarget() {
    if (config.target?.isObjectCollision() == true) {
      return (config.target as ObjectCollision).rectCollision.center;
    }
    return config.target?.position.rect.center ?? Offset.zero;
  }
}
