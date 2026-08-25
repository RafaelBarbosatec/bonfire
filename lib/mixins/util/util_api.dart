import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

/// API with general helper functions available in every [GameComponent].
///
/// Access it through the `util` object:
/// ```dart
/// component.util.showDamage(10);
/// component.util.getDirectionToTarget(enemy);
/// component.util.generateValues(...);
/// ```
class UtilApi {
  final GameComponent comp;

  UtilApi(this.comp);

  /// Add in the game a text with animation representing damage received.
  void showDamage(
    double damage, {
    TextStyle? config,
    double initVelocityVertical = -5,
    double initVelocityHorizontal = 1,
    double gravity = 0.5,
    double maxDownSize = 20,
    DirectionTextDamage direction = DirectionTextDamage.RANDOM,
    bool onlyUp = false,
  }) {
    if (!comp.hasGameRef) {
      return;
    }
    comp.gameRef.add(
      TextDamageComponent(
        damage.toInt().toString(),
        Vector2(comp.rectCollision.center.dx, comp.rectCollision.top),
        config: config ??
            const TextStyle(
              fontSize: 14,
              color: Color(0xFFFFFFFF),
            ),
        initVelocityVertical: initVelocityVertical,
        initVelocityHorizontal: initVelocityHorizontal,
        gravity: gravity,
        direction: direction,
        onlyUp: onlyUp,
        maxDownSize: maxDownSize,
      ),
    );
  }

  /// Get angle between this comp to target.
  double getAngleToTarget(GameComponent target) {
    return BonfireUtil.angleBetweenPointsOffset(
      comp.rectCollision.center,
      target.rectCollision.center,
    );
  }

  /// Get direction between this comp to target.
  Direction getDirectionToTarget(
    GameComponent target, {
    bool withDiagonal = true,
  }) {
    return BonfireUtil.getDirectionFromAngle(
      getAngleToTarget(target),
      directionSpace: withDiagonal ? 2.5 : 45,
    );
  }

  /// Gives the direction of the player in relation to this component.
  Direction? getDirectionToPlayer() {
    final player = comp.gameRef.player;
    if (player == null) {
      return null;
    }
    return getDirectionToTarget(player);
  }

  /// Get angle between this comp and player (player as base).
  double getAngleToPlayer() {
    final player = comp.gameRef.player;
    if (player == null) {
      return 0.0;
    }
    return getAngleToTarget(player);
  }

  /// Get angle between this comp and player (this comp position as base).
  double getInverseAngleToPlayer() {
    final player = comp.gameRef.player;
    if (player == null) {
      return 0.0;
    }
    return BonfireUtil.angleBetweenPoints(
      player.rectCollision.center.toVector2(),
      comp.rectCollision.centerVector2,
    );
  }

  /// Gets player position used how base in calculations.
  Rect get playerRect {
    return comp.gameRef.player?.rectCollision ?? Rect.zero;
  }

  Direction? directionThePlayerIsIn() {
    final player = comp.gameRef.player;
    if (player == null) {
      return null;
    }
    var diffX = comp.center.x - player.center.x;
    final diffPositiveX = diffX < 0 ? diffX *= -1 : diffX;
    var diffY = comp.center.y - player.center.y;
    final diffPositiveY = diffY < 0 ? diffY *= -1 : diffY;

    if (diffPositiveX > diffPositiveY) {
      if (player.center.x > comp.center.x) {
        return Direction.right;
      } else if (player.center.x < comp.center.x) {
        return Direction.left;
      }
    } else {
      if (player.center.y > comp.center.y) {
        return Direction.down;
      } else if (player.center.y < comp.center.y) {
        return Direction.up;
      }
    }

    return null;
  }

  /// Top edge of the component.
  double get top => comp.position.y;

  /// Bottom edge of the component.
  double get bottom => comp.absolutePositionOfAnchor(Anchor.bottomRight).y;

  /// Left edge of the component.
  double get left => comp.position.x;

  /// Right edge of the component.
  double get right => comp.absolutePositionOfAnchor(Anchor.bottomRight).x;

  /// Checks if this component overlaps the [other] rect.
  bool overlaps(Rect other) {
    if (right <= other.left || other.right <= left) {
      return false;
    }
    if (bottom <= other.top || other.bottom <= top) {
      return false;
    }
    return true;
  }

  /// Checks if this component is close to [target].
  bool isCloseTo(GameComponent target, {double distance = 5}) {
    final rectPlayerCollision = target.rectCollision.inflate(distance);
    return comp.rectCollision.overlaps(rectPlayerCollision);
  }

  /// Used to generate numbers to create your animations or anythings.
  ValueGeneratorComponent generateValues(
    Duration duration, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.linear,
    Curve? reverseCurve,
    bool autoStart = true,
    bool infinite = false,
    VoidCallback? onFinish,
    ValueChanged<double>? onChange,
  }) {
    final valueGenerator = ValueGeneratorComponent(
      duration,
      end: end,
      begin: begin,
      curve: curve,
      reverseCurve: reverseCurve,
      onFinish: onFinish,
      onChange: onChange,
      autoStart: autoStart,
      infinite: infinite,
    );
    comp.add(valueGenerator);
    return valueGenerator;
  }

  /// Used to add particles in your component.
  void addParticle(
    Particle particle, {
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
    ComponentKey? key,
  }) {
    comp.add(
      ParticleSystemComponent(
        particle: particle,
        position: position,
        size: size,
        scale: scale,
        angle: angle,
        anchor: anchor,
        priority: priority,
        key: key,
      ),
    );
  }

  Future<ParallaxComponent> loadParallaxComponent(
    Iterable<ParallaxData> dataList, {
    Vector2? baseVelocity,
    Vector2? velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images? images,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
    FilterQuality? filterQuality,
    ComponentKey? key,
  }) {
    return ParallaxComponent.load(
      dataList,
      baseVelocity: baseVelocity,
      velocityMultiplierDelta: velocityMultiplierDelta,
      repeat: repeat,
      alignment: alignment,
      fill: fill,
      images: images,
      position: position,
      size: size ?? comp.gameRef.camera.canvasSize,
      scale: scale,
      angle: angle,
      anchor: anchor,
      priority: priority,
      filterQuality: filterQuality,
      key: key,
    );
  }

  Future<ParallaxComponent> loadCameraParallaxComponent(
    Iterable<ParallaxData> dataList, {
    Vector2? baseVelocity,
    Vector2? velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images? images,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
    FilterQuality? filterQuality,
    ComponentKey? key,
  }) {
    return CameraParallaxComponent.load(
      dataList,
      baseVelocity: baseVelocity,
      velocityMultiplierDelta: velocityMultiplierDelta,
      repeat: repeat,
      alignment: alignment,
      fill: fill,
      images: images,
      position: position,
      size: size ?? comp.gameRef.camera.canvasSize,
      scale: scale,
      angle: angle,
      anchor: anchor,
      priority: priority,
      filterQuality: filterQuality,
      key: key,
    );
  }

  Offset globalToViewportPosition(Offset position) {
    if (!comp.hasGameRef) {
      return position;
    }
    return comp.gameRef
        .globalToViewportPosition(position.toVector2())
        .toOffset();
  }

  Offset viewportPositionToGlobal(Offset position) {
    if (!comp.hasGameRef) {
      return position;
    }
    return comp.gameRef
        .viewportPositionToGlobal(position.toVector2())
        .toOffset();
  }
}
