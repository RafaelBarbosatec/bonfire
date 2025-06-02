import 'package:bonfire/base/bonfire_collision_config.dart';
import 'package:bonfire/base/bonfire_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';

class BonfireWithCollision extends BonfireGame with HasCollisionDetection {
  final BonfireCollisionConfigDefault configDefault;
  BonfireWithCollision({
    required super.context,
    required super.map,
    required this.configDefault,
    super.playerControllers,
    super.player,
    super.interface,
    super.components,
    super.hudComponents,
    super.background,
    super.debugMode = false,
    super.showCollisionArea = false,
    super.collisionAreaColor,
    super.lightingColorGame,
    super.onReady,
    super.backgroundColor,
    super.colorFilter,
    super.cameraConfig,
    super.globalForces,
  }) {
    if (configDefault.customBroadPhase != null) {
      collisionDetection = StandardCollisionDetection(
        broadphase: configDefault.customBroadPhase,
      );
    }
  }

  @override
  void configCollisionDetection(Rect mapDimensions) {}

  @override
  Iterable<ShapeHitbox> collisions({bool onlyVisible = false}) {
    if (onlyVisible) {
      return collisionDetection.items.where(isVisibleInCamera);
    }
    return collisionDetection.items;
  }

  @override
  List<RaycastResult<ShapeHitbox>> raycastAll(
    Vector2 origin, {
    required int numberOfRays,
    double startAngle = 0,
    double sweepAngle = tau,
    double? maxDistance,
    List<Ray2>? rays,
    List<ShapeHitbox>? ignoreHitboxes,
    List<RaycastResult<ShapeHitbox>>? out,
  }) {
    return collisionDetection.raycastAll(
      origin,
      numberOfRays: numberOfRays,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
      maxDistance: maxDistance,
      rays: rays,
      ignoreHitboxes: ignoreHitboxes,
      out: out,
    );
  }

  @override
  RaycastResult<ShapeHitbox>? raycast(
    Ray2 ray, {
    double? maxDistance,
    List<ShapeHitbox>? ignoreHitboxes,
    RaycastResult<ShapeHitbox>? out,
  }) {
    return collisionDetection.raycast(
      ray,
      maxDistance: maxDistance,
      ignoreHitboxes: ignoreHitboxes,
      out: out,
    );
  }

  @override
  Iterable<RaycastResult<ShapeHitbox>> raytrace(
    Ray2 ray, {
    int maxDepth = 10,
    List<ShapeHitbox>? ignoreHitboxes,
    List<RaycastResult<ShapeHitbox>>? out,
  }) {
    return collisionDetection.raytrace(
      ray,
      maxDepth: maxDepth,
      ignoreHitboxes: ignoreHitboxes,
      out: out,
    );
  }
}
