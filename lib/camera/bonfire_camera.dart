import 'package:bonfire/bonfire.dart';
import 'package:bonfire/camera/camera_effects.dart';
import 'package:flame/experimental.dart';

class BonfireCamera extends CameraComponent with BonfireHasGameRef {
  double _spacingMap = 32.0;
  final CameraConfig config;
  BonfireCamera({
    required super.world,
    required this.config,
    super.hudComponents,
    super.viewport,
  }) {
    viewfinder.zoom = config.zoom;
    viewfinder.angle = config.angle;
    if (config.target != null) {
      follow(config.target!, snap: true);
    }
  }

  Rect get cameraRectWithSpacing => visibleWorldRect.inflate(_spacingMap);

  Vector2 get position => viewfinder.position;
  set position(Vector2 position) => viewfinder.position = position;
  Vector2 get topleft => visibleWorldRect.positionVector2;

  double get zoom => viewfinder.zoom;

  @override
  bool canSee(PositionComponent component) {
    return visibleWorldRect.overlaps(component.toAbsoluteRect());
  }

  bool canSeeWithMargin(PositionComponent component) {
    return cameraRectWithSpacing.overlaps(component.toAbsoluteRect());
  }

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
    required EffectController effectController,
    double? zoom,
    double? angle,
    Function()? onComplete,
  }) {
    stop();
    final moveToEffect = MoveToEffect(
      position,
      effectController,
      onComplete: onComplete,
    );
    viewfinder.add(moveToEffect);
    if (zoom != null) {
      final zoomEffect = ScaleEffect.to(
        Vector2.all(zoom),
        effectController,
      );
      zoomEffect.removeOnFinish = true;
      viewfinder.add(zoomEffect);
    }
    if (angle != null) {
      final rotateEffect = RotateEffect.to(
        angle,
        effectController,
      );
      rotateEffect.removeOnFinish = true;
      viewfinder.add(rotateEffect);
    }
  }

  void moveToTargetAnimated({
    required GameComponent target,
    required EffectController effectController,
    double? zoom,
    double? angle,
    Function()? onComplete,
  }) {
    moveToPositionAnimated(
      position: target.absolutePosition,
      effectController: effectController,
      zoom: zoom,
      angle: angle,
      onComplete: onComplete,
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
    PositionProvider target, {
    double maxSpeed = double.infinity,
    bool horizontalOnly = false,
    bool verticalOnly = false,
    bool snap = false,
  }) {
    stop();
    viewfinder.add(
      MyFollowBehavior(
        target: target,
        owner: viewfinder,
        maxSpeed: config.speed,
      ),
    );
    if (snap) {
      viewfinder.position = target.position;
    }
  }

  void moveToPlayerAnimated({
    required EffectController effectController,
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
        onComplete: () {
          onComplete?.call();
          follow(i);
        },
      );
    });
  }

  void animateZoom({
    required Vector2 zoom,
    required EffectController effectController,
    Function()? onComplete,
  }) {
    final zoomEffect = ScaleEffect.to(
      zoom,
      effectController,
      onComplete: onComplete,
    );
    zoomEffect.removeOnFinish = true;
    viewfinder.add(zoomEffect);
  }

  void animateAngle({
    required double angle,
    required EffectController effectController,
    Function()? onComplete,
  }) {
    final rotateEffect = RotateEffect.to(
      angle,
      effectController,
      onComplete: onComplete,
    );
    rotateEffect.removeOnFinish = true;
    viewfinder.add(rotateEffect);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    updatesetBounds();
  }

  void updatesetBounds() {
    if (config.moveOnlyMapArea && viewfinder.isMounted) {
      setBounds(
        Rectangle.fromRect(
          gameRef.map.getRect().deflatexy(
                visibleWorldRect.width / 2,
                visibleWorldRect.height / 2,
              ),
        ),
      );
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
}
