import 'package:bonfire/bonfire.dart';
import 'package:flame/experimental.dart';

class BonfireCameraV2 extends CameraComponent with BonfireHasGameRef {
  double _spacingMap = 32.0;
  final CameraConfig config;
  BonfireCameraV2({
    Iterable<Component>? childen,
    required this.config,
    super.hudComponents,
    super.viewport,
  }) : super(world: World(children: childen)) {
    viewfinder.zoom = config.zoom;
    viewfinder.angle = config.angle;
  }

  Rect get cameraRectWithSpacing => visibleWorldRect.inflate(_spacingMap);

  void updateSpacingVisibleMap(double space) {
    _spacingMap = space;
  }

  void moveTop(double displacement) {
    moveTo(viewfinder.position.translated(0, displacement * -1));
  }

  void moveRight(double displacement) {
    moveTo(viewfinder.position.translated(displacement, 0));
  }

  void moveLeft(double displacement) {
    moveTo(viewfinder.position.translated(displacement * -1, 0));
  }

  void moveDown(double displacement) {
    moveTo(viewfinder.position.translated(0, displacement));
  }

  void moveUp(double displacement) {
    moveTo(viewfinder.position.translated(displacement * -1, 0));
  }

  void moveToPositionAnimated({
    required Vector2 position,
    required EffectController effectController,
    Vector2? zoom,
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
        zoom,
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
    Vector2? zoom,
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

  void moveToPlayer() {
    gameRef.player.let((i) {
      follow(i);
    });
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
        zoom: Vector2(zoom ?? 1, zoom ?? 1),
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
  void onMount() {
    super.onMount();
    if (config.moveOnlyMapArea) {
      setBounds(Rectangle.fromRect(gameRef.map.toAbsoluteRect()));
    }
  }
}
