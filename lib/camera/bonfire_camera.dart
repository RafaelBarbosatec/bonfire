import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

class BonfireCamera extends Camera {
  bool _isMoving = false;
  bool moveOnlyMapArea = false;
  bool smoothCameraEnabled = false;
  double _spacingMap = 32.0;
  double angle = 0;
  Vector2 sizeMovementWindow = CameraConfig.sizeWidowsDefault;
  GameComponent? target;
  late BonfireGame gameRef;

  Size? _lastMapSize;
  double limitMinX = 0;
  double limitMinY = 0;
  double limitMaxX = 0;
  double limitMaxY = 0;

  BonfireCamera(
    CameraConfig config,
  ) {
    sizeMovementWindow = config.sizeMovementWindow;
    smoothCameraEnabled = config.smoothCameraEnabled;
    speed = config.smoothCameraSpeed;
    zoom = config.zoom;
    angle = config.angle;
    target = config.target;
    moveOnlyMapArea = config.moveOnlyMapArea;
  }

  bool get isMoving => _isMoving;

  Rect get cameraRect => Rect.fromLTWH(
        position.x,
        position.y,
        (canvasSize.x * _zoomFactor()),
        (canvasSize.y * _zoomFactor()),
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

  void moveLeft(double displacement) {
    snapTo(position.translate(displacement * -1, 0));
  }

  void moveDown(double displacement) {
    snapTo(position.translate(0, displacement));
  }

  void moveUp(double displacement) {
    snapTo(position.translate(displacement * -1, 0));
  }

  void moveToPositionAnimated(
    Vector2 position, {
    double? zoom,
    double? angle,
    VoidCallback? finish,
    Duration? duration,
    Curve curve = Curves.decelerate,
  }) {
    if ((zoom != null && zoom <= 0.0) || _isMoving) return;
    this.target = null;
    _isMoving = true;

    double newZoom = zoom ?? this.zoom;
    double newAngle = angle ?? this.angle;
    double diffX = this.position.x - position.x;
    double diffY = this.position.y - position.y;
    double originX = this.position.x;
    double originY = this.position.y;

    double diffZoom = this.zoom - newZoom;
    double initialZoom = this.zoom;

    double diffAngle = this.angle - newAngle;
    double originAngle = this.angle;

    gameRef.getValueGenerator(
      duration ?? Duration(seconds: 1),
      onChange: (value) {
        snapTo(
          Vector2(
            originX - (diffX * value),
            originY - (diffY * value),
          ),
        );

        this.zoom = initialZoom - (diffZoom * value);
        this.angle = originAngle - (diffAngle * value);
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
    double? zoom,
    double? angle,
    VoidCallback? finish,
    Duration? duration,
    Curve curve = Curves.decelerate,
  }) {
    if ((zoom != null && zoom <= 0.0) || _isMoving) return;
    this.target = null;
    _isMoving = true;

    double newZoom = zoom ?? this.zoom;
    double newAngle = angle ?? this.angle;
    Vector2 originPosition = this.position.clone();

    double diffZoom = this.zoom - newZoom;
    double initialZoom = this.zoom;

    double diffAngle = this.angle - newAngle;
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
    double? zoom,
    double? angle,
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
    Vector2? sizeWindows,
  }) {
    if (this.target != null && !_isMoving) {
      _moveCameraToTarget(
        dt,
        enableSmooth: this.smoothCameraEnabled,
        sizeWindows: sizeWindows ?? CameraConfig.sizeWidowsDefault,
      );
    }
  }

  void _moveCameraToTarget(
    double dt, {
    Vector2? sizeWindows,
    bool enableSmooth = false,
  }) {
    Vector2 sizeW = sizeWindows ?? CameraConfig.sizeWidowsDefault;
    double horizontal = sizeW.x;
    double vertical = sizeW.y;

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

    bool shouldMove = false;
    if (horizontalDistance.abs() > horizontal) {
      double displacementX = _getMoveDisplacement(
        horizontal,
        horizontalDistance,
      );
      newX = this.position.x + (displacementX * _zoomFactor());
      shouldMove = true;
    }

    if (verticalDistance.abs() > vertical) {
      double displacementY = _getMoveDisplacement(
        vertical,
        verticalDistance,
      );
      newY = this.position.y + (displacementY * _zoomFactor());
      shouldMove = true;
    }

    if (shouldMove) {
      snapTo(this.position.copyWith(
            x: enableSmooth
                ? lerpDouble(this.position.x, newX, dt * speed)
                : newX,
            y: enableSmooth
                ? lerpDouble(this.position.y, newY, dt * speed)
                : newY,
          ));
    }
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
    return cameraRectWithSpacing.overlapComponent(c);
  }

  bool contains(Offset c) {
    return cameraRectWithSpacing.contains(c);
  }

  bool isRectOnCamera(Rect c) {
    return cameraRectWithSpacing.overlaps(c);
  }

  void update(double dt) {
    super.update(dt);
    _updateLimits(canvasSize);
    if (dt != 0 && gameRef.isLoaded == true) {
      _followTarget(
        dt,
        sizeWindows: this.sizeMovementWindow,
      );
    }
  }

  void updateSpacingVisibleMap(double space) {
    _spacingMap = space;
  }

  void _updateLimits(Vector2 canvasSize) {
    final startPosition = gameRef.map.mapStartPosition;
    final sizeMap = gameRef.map.mapSize;

    if (startPosition == null || sizeMap == null) return;
    if (_lastMapSize != sizeMap) {
      _lastMapSize = sizeMap;
      limitMinX = startPosition.x;
      limitMinY = startPosition.y;
      limitMaxX =
          (sizeMap.width + startPosition.x - (canvasSize.x * _zoomFactor()));
      limitMaxY =
          (sizeMap.height + startPosition.y - (canvasSize.y * _zoomFactor()));
    }
  }

  Vector2 _verifyLimits(Vector2 position) {
    if (!this.moveOnlyMapArea) {
      return position;
    }

    Vector2 newPosition = position.clone();

    if (position.x > limitMaxX) {
      newPosition = newPosition.copyWith(
        x: limitMaxX,
      );
    } else if (position.x < limitMinX) {
      newPosition = newPosition.copyWith(
        x: limitMinX,
      );
    }

    if (position.y > limitMaxY) {
      newPosition = newPosition.copyWith(
        y: limitMaxY,
      );
    } else if (position.y < limitMinY) {
      newPosition = newPosition.copyWith(
        y: limitMinY,
      );
    }

    return newPosition;
  }

  void snapTo(Vector2 position) {
    super.snapTo(_verifyLimits(position));
  }

  double _zoomFactor() {
    return 1 / this.zoom;
  }

  Vector2 _getCenterTarget() {
    if (this.target?.isObjectCollision() == true) {
      return (this.target as ObjectCollision).rectCollision.center.toVector2();
    }
    return this.target?.center ?? Vector2.zero();
  }

  double _getMoveDisplacement(double baseValue, double distance) {
    if (distance > 0) {
      return baseValue - distance;
    }
    return -distance - baseValue;
  }

  @override
  void followComponent(
    PositionComponent component, {
    Anchor relativeOffset = Anchor.center,
    Rect? worldBounds,
  }) {
    print('followComponent method not work in Bonfire. Use moveToTarget');
  }

  @override
  void followVector2(
    Vector2 vector2, {
    Anchor relativeOffset = Anchor.center,
    Rect? worldBounds,
  }) {
    print('followVector2 method not work in Bonfire.');
  }
}
