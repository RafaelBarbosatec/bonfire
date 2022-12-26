import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

class BonfireCamera extends Camera {
  bool _isMoving = false;
  bool moveOnlyMapArea = false;
  bool smoothCameraEnabled = false;
  bool setZoomLimitToFitMap = false;
  double _spacingMap = 32.0;
  double angle = 0;
  Vector2 sizeMovementWindow = CameraConfig.sizeWidowsDefault;
  GameComponent? target;
  late BonfireGame gameRef;

  double? _lastZoomSize;
  double limitMinX = 0;
  double limitMinY = 0;
  double limitMaxX = 0;
  double limitMaxY = 0;

  Offset screenCenter = Offset.zero;

  BonfireCamera(
    CameraConfig config,
  ) {
    setZoomLimitToFitMap = config.setZoomLimitToFitMap;
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
    target = null;
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

    _generateValues(
      duration ?? const Duration(seconds: 1),
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
    );
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
    Vector2 originPosition = position.clone();

    double diffZoom = this.zoom - newZoom;
    double initialZoom = this.zoom;

    double diffAngle = this.angle - newAngle;
    double originAngle = this.angle;

    _generateValues(
      duration ?? const Duration(seconds: 1),
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
    );
  }

  void moveToPosition(Vector2 position) {
    target = null;
    snapTo(position);
  }

  void moveToPlayer() {
    target = gameRef.player;
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
    if (target != null && !_isMoving) {
      _moveCameraToTarget(
        dt,
        enableSmooth: smoothCameraEnabled,
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

    final centerTarget = _getCenterTarget();
    final positionTarget = worldToScreen(centerTarget);

    final horizontalDistance = screenCenter.dx - positionTarget.x;
    final verticalDistance = screenCenter.dy - positionTarget.y;

    double newX = position.x;
    double newY = position.y;
    double zoomFactor = _zoomFactor();

    bool shouldMove = false;
    if (horizontalDistance.abs() > horizontal) {
      double displacementX = _getMoveDisplacement(
        horizontal,
        horizontalDistance,
      );
      newX = position.x + (displacementX * zoomFactor);

      shouldMove = true;
    }

    if (verticalDistance.abs() > vertical) {
      double displacementY = _getMoveDisplacement(
        vertical,
        verticalDistance,
      );
      newY = position.y + (displacementY * zoomFactor);

      shouldMove = true;
    }

    if (position.x == newX && position.y == newY) {
      shouldMove = false;
    }

    if (shouldMove) {
      if (enableSmooth) {
        double camSpeed = dt * speed;
        newX = lerpDouble(position.x, newX, camSpeed) ?? newX;
        newY = lerpDouble(position.y, newY, camSpeed) ?? newY;
      }
      snapTo(Vector2(newX, newY));
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

    _generateValues(
      duration ?? const Duration(seconds: 1),
      onChange: (value) {
        this.zoom = initialZoom - (diffZoom * value);
      },
      onFinish: () {
        _isMoving = false;
        finish?.call();
      },
      curve: curve,
    );
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

    _generateValues(
      duration ?? const Duration(seconds: 1),
      onChange: (value) {
        this.angle = originAngle - (diffAngle * value);
      },
      onFinish: () {
        _isMoving = false;
        onFinish?.call();
      },
      curve: curve,
    );
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
    return cameraRectWithSpacing.overlapComponent(c) ||
        c.positionType == PositionType.viewport;
  }

  bool contains(Offset c) {
    return cameraRectWithSpacing.contains(c);
  }

  bool isRectOnCamera(Rect c) {
    return cameraRectWithSpacing.overlaps(c);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _updateLimits(canvasSize);
    if (dt != 0 && gameRef.isLoaded == true) {
      _followTarget(
        dt,
        sizeWindows: sizeMovementWindow,
      );
    }
  }

  void updateSpacingVisibleMap(double space) {
    _spacingMap = space;
  }

  void onGameResize(Vector2 canvasSize) {
    screenCenter = Offset(
      canvasSize.x / 2,
      canvasSize.y / 2,
    );
  }

  void _updateLimits(Vector2 canvasSize) {
    final mapSize = gameRef.map.size;

    if (_lastZoomSize != zoom && mapSize != Vector2.zero()) {
      _updateZoomLimits(canvasSize, mapSize);
      _lastZoomSize = zoom;
      final startPosition = gameRef.map.getStartPosition();
      limitMinX = startPosition.x;
      limitMinY = startPosition.y;

      double width = canvasSize.x;
      double height = canvasSize.y;
      double zoomFactor = _zoomFactor();

      final sizeMap = gameRef.map.size;

      if (sizeMap.x < canvasSize.x) {
        width = sizeMap.x;
      }
      if (sizeMap.y < canvasSize.y) {
        height = sizeMap.y;
      }

      limitMaxX = mapSize.x - (width * zoomFactor);
      limitMaxY = mapSize.y - (height * zoomFactor);
    }
  }

  Vector2 _verifyLimits(Vector2 position) {
    if (!moveOnlyMapArea) {
      return position;
    }

    position.x = _verifyXlimits(position.x);
    position.y = _verifyYlimits(position.y);

    return position;
  }

  double _verifyXlimits(double dx) {
    if (dx > limitMaxX) {
      return limitMaxX;
    } else if (dx < limitMinX) {
      return limitMinX;
    }
    return dx;
  }

  double _verifyYlimits(double dy) {
    if (dy > limitMaxY) {
      return limitMaxY;
    } else if (dy < limitMinY) {
      return limitMinY;
    }
    return dy;
  }

  @override
  void snapTo(Vector2 position) {
    super.snapTo(_verifyLimits(position));
  }

  double _zoomFactor() {
    return 1 / zoom;
  }

  Vector2 _getCenterTarget() {
    if (target?.isObjectCollision() == true) {
      return (target as ObjectCollision).rectCollision.center.toVector2();
    }
    return target?.center ?? Vector2.zero();
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
    // ignore: avoid_print
    print('followComponent method not work in Bonfire. Use moveToTarget');
  }

  @override
  void followVector2(
    Vector2 vector2, {
    Anchor relativeOffset = Anchor.center,
    Rect? worldBounds,
  }) {
    // ignore: avoid_print
    print('followVector2 method not work in Bonfire.');
  }

  void _generateValues(
    Duration duration, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.decelerate,
    VoidCallback? onFinish,
    ValueChanged<double>? onChange,
  }) {
    gameRef.add(
      ValueGeneratorComponent(
        duration,
        end: end,
        begin: begin,
        curve: curve,
        autoStart: true,
        onFinish: onFinish,
        onChange: onChange,
      ),
    );
  }

  void _updateZoomLimits(Vector2 canvasSize, Vector2 mapSize) {
    if (setZoomLimitToFitMap) {
      double minZoom = zoom;
      if (mapSize.x < mapSize.y) {
        minZoom = canvasSize.x / (mapSize.x - gameRef.map.getStartPosition().x);
      }

      if (mapSize.y < mapSize.x) {
        minZoom = canvasSize.y / (mapSize.y - gameRef.map.getStartPosition().y);
      }

      if (zoom < minZoom) {
        zoom = minZoom;
      }
    }
  }
}
