import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/base/rpg_game.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flutter/widgets.dart';

class Camera with HasGameRef<RPGGame> {
  Position position = Position.empty();
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
        center: Offset(position.x, position.y),
        width: gameRef.size.width / zoom + 80,
        height: gameRef.size.height / zoom + 80,
      );

  void moveTop(double displacement) {
    position.y = position.y - displacement;
  }

  void moveRight(double displacement) {
    position.x = position.x + displacement;
  }

  void moveBottom(double displacement) {
    position.y = position.y + displacement;
  }

  void moveLeft(double displacement) {
    position.x = position.x - displacement;
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
    Position position, {
    double zoom = 1,
    VoidCallback finish,
    Duration duration,
    Curve curve = Curves.decelerate,
  }) {
    if (gameRef?.size == null) return;
    if (zoom <= 0.0) return;
    target = null;

    double diffX = this.position.x - position.x;
    double diffY = this.position.y - position.y;
    double originX = this.position.x;
    double originY = this.position.y;

    double diffZoom = this.zoom - zoom;
    double initialZoom = this.zoom;

    gameRef
        .getValueGenerator(
          duration ?? Duration(seconds: 1),
          onChange: (value) {
            this.position.x = originX - (diffX * value);
            this.position.y = originY - (diffY * value);
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

    double diffX = this.position.x - target.position.center.dx;
    double diffY = this.position.y - target.position.center.dy;
    double originX = this.position.x;
    double originY = this.position.y;

    double diffZoom = this.zoom - zoom;
    double initialZoom = this.zoom;

    gameRef.getValueGenerator(
      duration ?? Duration(seconds: 1),
      onChange: (value) {
        this.position.x = originX - (diffX * value);
        this.position.y = originY - (diffY * value);
        this.zoom = initialZoom - (diffZoom * value);
      },
      onFinish: () {
        this.target = target;
        finish?.call();
      },
      curve: curve,
    ).start();
  }

  void moveToPosition(Position position) {
    if (gameRef?.size == null) return;
    target = null;
    this.position = position;
  }

  void moveToPlayerAnimated({
    Duration duration,
    VoidCallback finish,
    double zoom = 1,
  }) {
    if (gameRef.player == null) return;
    moveToTargetAnimated(
      gameRef.player,
      zoom: zoom,
      finish: finish,
      duration: duration,
    );
  }

  void _followTarget({double horizontal = 50, double vertical = 50}) {
    if (target == null || gameRef?.size == null) return;
    if (_lastTargetOffset == target.position.center) return;
    _lastTargetOffset = target.position.center;
    final screenCenter = Offset(
      gameRef.size.width / 2,
      gameRef.size.height / 2,
    );
    final positionTarget = worldPositionToScreen(target.position.center);

    final horizontalDistance = screenCenter.dx - positionTarget.dx;
    final verticalDistance = screenCenter.dy - positionTarget.dy;

    if (horizontalDistance.abs() > horizontal) {
      this.position.x += horizontalDistance > 0
          ? horizontal - horizontalDistance
          : -horizontalDistance - horizontal;
    }
    if (verticalDistance.abs() > vertical) {
      this.position.y += verticalDistance > 0
          ? vertical - verticalDistance
          : -verticalDistance - vertical;
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

    return cameraRect.overlaps(c.position);
  }

  Offset worldPositionToScreen(Offset position) {
    return position.translate(
      -gameRef.gameCamera.position.x + gameRef.size.width / 2,
      -gameRef.gameCamera.position.y + gameRef.size.height / 2,
    );
  }

  Offset cameraPositionToWorld(Offset position) {
    return position.translate(
      gameRef.gameCamera.position.x - gameRef.size.width / 2,
      gameRef.gameCamera.position.y - gameRef.size.height / 2,
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
    final limitX = (startPosition.x + gameRef.size.width / 2);
    final limitY = (startPosition.y + gameRef.size.height / 2);
    final limitMaxX = (sizeMap.width - gameRef.size.width / 2);
    final limitMaxY = (sizeMap.height - gameRef.size.height / 2);

    if (this.position.x > limitMaxX) {
      this.position.x = limitMaxX;
    }
    if (this.position.y > limitMaxY) {
      this.position.y = limitMaxY;
    }

    if (this.position.x < limitX) {
      this.position.x = limitX;
    }
    if (this.position.y < limitY) {
      this.position.y = limitY;
    }
  }
}
