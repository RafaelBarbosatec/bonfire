import 'package:bonfire/bonfire.dart';
import 'package:bonfire/camera/camera_effects.dart';
import 'package:flame/experimental.dart';

// Custom implmentation of Flame's `CameraComponent`
class BonfireCamera extends CameraComponent with BonfireHasGameRef {
  double _spacingMap = 32.0;
  final CameraConfig config;
  BonfireCamera({
    CameraConfig? config,
    super.world,
    super.hudComponents,
    super.viewport,
    super.backdrop,
  }) : config = config ?? CameraConfig() {
    if (this.config.initPosition != null) {
      position = this.config.initPosition!;
    }
    viewfinder.zoom = this.config.zoom;
    viewfinder.angle = this.config.angle;
    if (this.config.target != null) {
      follow(this.config.target!, snap: true);
    }
  }

  Rect get cameraRectWithSpacing =>
      visibleWorldRect.inflate(_spacingMap / zoom);

  Vector2 get position => viewfinder.position;

  Vector2 get visibleSize => visibleWorldRect.sizeVector2;
  set position(Vector2 position) => viewfinder.position = position;
  Vector2 get topleft => visibleWorldRect.positionVector2;

  double get zoom => viewfinder.zoom;
  set zoom(double scale) => viewfinder.zoom = scale;

  double get angle => viewfinder.angle;
  set angle(double angle) => viewfinder.angle = angle;

  bool canSeeWithMargin(PositionComponent component) {
    return cameraRectWithSpacing.overlaps(component.toAbsoluteRect());
  }

  // ignore: use_setters_to_change_properties
  void updateSpacingVisibleMap(double space) {
    _spacingMap = space;
  }

  void moveTop(double displacement) {
    position = position.translated(0, displacement * -1);
  }

  void moveRight(double displacement) {
    position = position.translated(displacement, 0);
  }

  void moveLeft(double displacement) {
    position = position.translated(displacement * -1, 0);
  }

  void moveDown(double displacement) {
    position = position.translated(0, displacement);
  }

  void moveUp(double displacement) {
    position = position.translated(displacement * -1, 0);
  }

  void moveToPositionAnimated({
    required Vector2 position,
    EffectController? effectController,
    double? zoom,
    double? angle,
    Function()? onComplete,
  }) {
    stop();
    final controller = effectController ?? EffectController(duration: 1);
    final moveToEffect = MoveToEffect(
      position,
      controller,
      onComplete: onComplete,
    );
    viewfinder.add(moveToEffect);
    if (zoom != null) {
      final zoomEffect = ScaleEffect.to(
        Vector2.all(zoom),
        controller,
      );
      zoomEffect.removeOnFinish = true;
      viewfinder.add(zoomEffect);
    }
    if (angle != null) {
      final rotateEffect = RotateEffect.to(
        angle,
        controller,
      );
      rotateEffect.removeOnFinish = true;
      viewfinder.add(rotateEffect);
    }
  }

  void moveToTargetAnimated({
    required PositionComponent target,
    EffectController? effectController,
    double? zoom,
    double? angle,
    Function()? onComplete,
    bool followTarget = true,
  }) {
    moveToPositionAnimated(
      position: target.position,
      effectController: effectController,
      zoom: zoom,
      angle: angle,
      onComplete: () {
        if (followTarget) {
          follow(target);
        }
        onComplete?.call();
      },
    );
  }

  void moveToPlayer({
    bool snap = true,
  }) {
    gameRef.player.let((i) {
      follow(i, snap: snap);
    });
  }

  @override
  void follow(
    ReadOnlyPositionProvider target, {
    double maxSpeed = double.infinity,
    bool horizontalOnly = false,
    bool verticalOnly = false,
    bool snap = false,
  }) {
    stop();
    viewfinder.add(
      MyFollowBehavior(
        target: target,
        targetSize: _getTargetSize(target),
        maxSpeed: config.speed,
        movementWindow: config.movementWindow,
        horizontalOnly: horizontalOnly,
        verticalOnly: verticalOnly,
      ),
    );
    if (snap) {
      viewfinder.position = target.position;
    }
  }

  void moveToPlayerAnimated({
    EffectController? effectController,
    Function()? onComplete,
    double? zoom,
    double? angle,
  }) {
    gameRef.player.let((i) {
      moveToTargetAnimated(
        target: i,
        effectController: effectController,
        zoom: zoom,
        angle: angle,
        onComplete: onComplete,
      );
    });
  }

  void animateZoom({
    required Vector2 zoom,
    EffectController? effectController,
    Function()? onComplete,
  }) {
    final zoomEffect = ScaleEffect.to(
      zoom,
      effectController ?? EffectController(duration: 1),
      onComplete: onComplete,
    );
    zoomEffect.removeOnFinish = true;
    viewfinder.add(zoomEffect);
  }

  void animateAngle({
    required double angle,
    EffectController? effectController,
    Function()? onComplete,
  }) {
    final rotateEffect = RotateEffect.to(
      angle,
      effectController ?? EffectController(duration: 1),
      onComplete: onComplete,
    );
    rotateEffect.removeOnFinish = true;
    viewfinder.add(rotateEffect);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    updateBoundsAndZoomFit();
  }

  void updateBoundsAndZoomFit({
    bool? moveOnlyMapArea,
    InitialMapZoomFitEnum? mapZoomFit,
  }) {
    this.mapZoomFit = mapZoomFit ?? config.initialMapZoomFit;
    this.moveOnlyMapArea = moveOnlyMapArea ?? config.moveOnlyMapArea;
  }

  set mapZoomFit(InitialMapZoomFitEnum value) {
    config.initialMapZoomFit = value;
    final sizeScreen = canvasSize;
    switch (value) {
      case InitialMapZoomFitEnum.none:
        break;
      case InitialMapZoomFitEnum.fitWidth:
        zoom = sizeScreen.x / gameRef.map.getMapSize().x;
        break;
      case InitialMapZoomFitEnum.fitHeight:
        zoom = sizeScreen.y / gameRef.map.getMapSize().y;
        break;
      case InitialMapZoomFitEnum.fit:
        if (sizeScreen.x > sizeScreen.y) {
          zoom = sizeScreen.x / gameRef.map.getMapSize().x;
        } else {
          zoom = sizeScreen.y / gameRef.map.getMapSize().y;
        }
        break;
    }
  }

  Vector2 get canvasSize => viewport.size;

  set moveOnlyMapArea(bool enabled) {
    if (!viewfinder.isMounted) {
      return;
    }
    config.moveOnlyMapArea = enabled;
    if (enabled) {
      setBounds(
        Rectangle.fromRect(
          gameRef.map.getMapRect().deflatexy(
                visibleWorldRect.width / 2,
                visibleWorldRect.height / 2,
              ),
        ),
      );
    } else {
      setBounds(null);
    }
  }

  Vector2 worldToScreen(Vector2 worldPosition) {
    return (worldPosition - topleft) * zoom;
  }

  Vector2 screenToWorld(Vector2 position) {
    return topleft + (position / zoom);
  }

  void shake({double intensity = 10.0, Duration? duration}) {
    viewfinder.add(
      ShakeEffect(
        intensity: intensity,
        duration: duration ?? const Duration(milliseconds: 300),
      ),
    );
  }

  Vector2? _getTargetSize(ReadOnlyPositionProvider target) {
    if (target is PositionComponent) {
      if (target.anchor == Anchor.topLeft) {
        return target.size;
      }
      if (target.anchor == Anchor.bottomRight) {
        return -target.size;
      }
    }
    return null;
  }
}
