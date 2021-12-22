import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import 'camera_config.dart';

class BonfireCamera extends Camera {
  bool _isMoving = false;
  bool moveOnlyMapArea = false;
  bool smoothCameraEnable = false;
  double _spacingMap = 32.0;
  double angle = 0;
  Vector2 sizeMovementWindow = Vector2(50, 50);
  GameComponent? target;
  late BonfireGame gameRef;

  BonfireCamera(
    CameraConfig config,
  ) {
    sizeMovementWindow = config.sizeMovementWindow;
    smoothCameraEnable = config.smoothCameraEnable;
    speed = config.smoothCameraSpeed;
    zoom = config.zoom;
    angle = config.angle;
    target = config.target;
    moveOnlyMapArea = config.moveOnlyMapArea;
    if (target != null) {
      snapTo(target!.position);
      followComponent(target!);
    }
  }

  bool get isMoving => _isMoving;

  Rect get cameraRect => Rect.fromLTWH(
        position.x,
        position.y,
        (canvasSize.x) * _zoomFactor(),
        (canvasSize.y) * _zoomFactor(),
      );

  Rect get cameraRectWithSpacing => Rect.fromLTWH(
        position.x - _spacingMap,
        position.y - _spacingMap,
        cameraRect.width + (_spacingMap * 2),
        cameraRect.height + (_spacingMap * 2),
      );

  void moveTop(double displacement) {
    snapTo(position.translate(0, displacement * -1));
  }

  void moveRight(double displacement) {
    snapTo(position.translate(displacement, 0));
  }

  void moveDown(double displacement) {
    snapTo(position.translate(0, displacement));
  }

  void moveUp(double displacement) {
    snapTo(position.translate(displacement * -1, 0));
  }

  void moveToPositionAnimated(
    Offset position, {
    double zoom = 1,
    double angle = 0,
    VoidCallback? finish,
    Duration? duration,
    Curve curve = Curves.decelerate,
  }) {
    if (zoom <= 0.0 || _isMoving) return;
    this.target = null;
    _isMoving = true;

    double diffX = this.position.x - position.dx;
    double diffY = this.position.y - position.dy;
    double originX = this.position.x;
    double originY = this.position.y;

    double diffZoom = this.zoom - zoom;
    double initialZoom = this.zoom;

    double diffAngle = this.angle - angle;
    double originAngle = this.angle;

    gameRef.getValueGenerator(
      duration ?? Duration(seconds: 1),
      onChange: (value) {
        snapTo(
          this.position.copyWith(
                x: originX - (diffX * value),
              ),
        );
        snapTo(
          this.position.copyWith(
                y: originY - (diffY * value),
              ),
        );
        this.zoom = initialZoom - (diffZoom * value);
        this.angle = originAngle - (diffAngle * value);

        if (this.moveOnlyMapArea) {
          _keepInMapArea();
        }
      },
      onFinish: () {
        _isMoving = false;
        finish?.call();
      },
      curve: curve,
    ).start();
  }

  void moveToTargetAnimated(
    GameComponent target, {
    double zoom = 1,
    double angle = 0,
    VoidCallback? finish,
    Duration? duration,
    Curve curve = Curves.decelerate,
  }) {
    if (zoom <= 0.0 || _isMoving) return;
    this.target = null;
    _isMoving = true;

    Vector2 originPosition = this.position.clone();

    double diffZoom = this.zoom - zoom;
    double initialZoom = this.zoom;

    double diffAngle = this.angle - angle;
    double originAngle = this.angle;

    gameRef.getValueGenerator(
      duration ?? Duration(seconds: 1),
      onChange: (value) {
        double diffX = (originPosition.x + gameSize.x / 2) - target.center.x;
        double diffY = (originPosition.y + gameSize.y / 2) - target.center.y;

        snapTo(
          Vector2(
            originPosition.x - (diffX * value),
            originPosition.y - (diffY * value),
          ),
        );
        this.zoom = initialZoom - (diffZoom * value);
        this.angle = originAngle - (diffAngle * value);

        if (this.moveOnlyMapArea) {
          _keepInMapArea();
        }
      },
      onFinish: () {
        this.target = target;
        _isMoving = false;
        finish?.call();
      },
      curve: curve,
    ).start();
  }

  void moveToPosition(Vector2 position) {
    target = null;
    snapTo(position);
  }

  void moveToPlayer() {
    this.target = gameRef.player;
  }

  void moveToTarget(GameComponent? target) {
    this.target = target;
  }

  void moveToPlayerAnimated({
    Duration? duration,
    VoidCallback? finish,
    double zoom = 1,
    double angle = 0,
    Curve curve = Curves.decelerate,
  }) {
    if (gameRef.player == null) return;
    moveToTargetAnimated(
      gameRef.player!,
      zoom: zoom,
      angle: angle,
      finish: finish,
      duration: duration,
      curve: curve,
    );
  }

  void _followTarget(
    double dt, {
    double sizeHorizontal = 50,
    double sizeVertical = 50,
  }) {
    if (this.target != null && !_isMoving) {
      _moveCameraToTarget(
        dt,
        enableSmooth: this.smoothCameraEnable,
        sizeHorizontal: sizeHorizontal,
        sizeVertical: sizeVertical,
      );
    }

    if (this.moveOnlyMapArea) {
      _keepInMapArea();
    }
  }

  void _moveCameraToTarget(
    double dt, {
    double sizeHorizontal = 50,
    double sizeVertical = 50,
    bool enableSmooth = false,
  }) {
    double horizontal = enableSmooth ? 0 : sizeHorizontal;
    double vertical = enableSmooth ? 0 : sizeVertical;

    final screenCenter = Offset(
      canvasSize.x / 2,
      canvasSize.y / 2,
    );

    final centerTarget = _getCenterTarget();
    final positionTarget = worldToScreen(centerTarget);

    final horizontalDistance = screenCenter.dx - positionTarget.x;
    final verticalDistance = screenCenter.dy - positionTarget.y;

    double newX = this.position.x;
    double newY = this.position.y;

    if (horizontalDistance.abs() > horizontal) {
      newX = this.position.x +
          (horizontalDistance > 0
              ? horizontal - horizontalDistance
              : -horizontalDistance - horizontal);
    }

    if (verticalDistance.abs() > vertical) {
      newY = this.position.y +
          (verticalDistance > 0
              ? vertical - verticalDistance
              : -verticalDistance - vertical);
    }

    snapTo(
      this.position.copyWith(
            x: enableSmooth
                ? lerpDouble(this.position.x, newX, dt * speed)
                : newX,
            y: enableSmooth
                ? lerpDouble(this.position.y, newY, dt * speed)
                : newY,
          ),
    );
  }

  void animateZoom({
    required double zoom,
    Duration? duration,
    VoidCallback? finish,
    Curve curve = Curves.decelerate,
  }) {
    if (zoom <= 0.0 || _isMoving) return;

    _isMoving = true;

    double diffZoom = this.zoom - zoom;
    double initialZoom = this.zoom;

    gameRef.getValueGenerator(
      duration ?? Duration(seconds: 1),
      onChange: (value) {
        this.zoom = initialZoom - (diffZoom * value);
      },
      onFinish: () {
        _isMoving = false;
        finish?.call();
      },
      curve: curve,
    ).start();
  }

  void animateSimpleRotation({
    required double angle,
    Duration? duration,
    VoidCallback? onFinish,
    Curve curve = Curves.decelerate,
  }) {
    _isMoving = true;

    final diffAngle = this.angle - angle;
    final originAngle = this.angle;

    gameRef.getValueGenerator(
      duration ?? const Duration(seconds: 1),
      onChange: (value) {
        this.angle = originAngle - (diffAngle * value);
      },
      onFinish: () {
        _isMoving = false;
        onFinish?.call();
      },
      curve: curve,
    ).start();
  }

  void animateLoopRotation({
    required List<double> angles,
    required int repeatCount,
    bool normalizeOnFinish = true,
    List<Duration>? pauseDuration,
    List<Duration>? rotationDuration,
    List<Curve>? curves,
    VoidCallback? onFinish,
  }) async {
    int currentRepetition = 0;
    int currentRotation = 0;

    while (currentRepetition < repeatCount) {
      currentRotation = 0;
      await Future.forEach<double>(angles, (rotateAngle) async {
        animateSimpleRotation(
          angle: rotateAngle,
          duration: rotationDuration?[currentRotation],
          curve: curves?[currentRotation] ?? Curves.decelerate,
        );
        await Future.delayed(
          pauseDuration?[currentRotation] ?? const Duration(seconds: 1),
        );
        currentRotation++;
      });
      currentRepetition++;
    }
    if (normalizeOnFinish) animateSimpleRotation(angle: 0.0);
    onFinish?.call();
  }

  bool isComponentOnCamera(GameComponent c) {
    return isRectOnCamera(c.toRect());
  }

  bool contains(Offset c) {
    return cameraRectWithSpacing.contains(c);
  }

  bool isRectOnCamera(Rect c) {
    return cameraRectWithSpacing.overlaps(c);
  }

  void update(double dt) {
    super.update(dt);
    if (dt != 0) {
      _followTarget(
        dt,
        sizeVertical: this.sizeMovementWindow.y,
        sizeHorizontal: this.sizeMovementWindow.x,
      );
    }
  }

  void updateSpacingVisibleMap(double space) {
    _spacingMap = space;
  }

  void _keepInMapArea() {
    final startPosition = gameRef.map.mapStartPosition;
    final sizeMap = gameRef.map.mapSize;
    if (startPosition == null || sizeMap == null) return;

    final limitX = (startPosition.x);
    final limitY = (startPosition.y);
    final limitMaxX = (sizeMap.width + startPosition.x - gameRef.canvasSize.x);
    final limitMaxY = (sizeMap.height + startPosition.y - gameRef.canvasSize.y);

    if (this.position.x > limitMaxX) {
      snapTo(Vector2(limitMaxX, position.y));
    }
    if (this.position.y > limitMaxY) {
      snapTo(Vector2(position.x, limitMaxY));
    }

    if (this.position.x < limitX) {
      snapTo(Vector2(limitX, position.y));
    }
    if (this.position.y < limitY) {
      snapTo(Vector2(position.x, limitY));
    }
  }

  double _zoomFactor() {
    if (this.zoom > 1) return 1;
    return 1 / this.zoom;
  }

  Vector2 _getCenterTarget() {
    if (this.target?.isObjectCollision() == true) {
      return (this.target as ObjectCollision).rectCollision.center.toVector2();
    }
    return this.target?.center ?? Vector2.zero();
  }
}
