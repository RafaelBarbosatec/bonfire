// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/polygons_intersect_util.dart';

export 'body_type.dart';
export 'collision_data.dart';

// Returns true to block movement, false to allow movement
typedef BlockMovementCallback = bool Function(
  Set<Vector2> intersectionPoints,
  GameComponent other,
);
typedef MovementBlockedCallback = void Function(
  PositionComponent other,
  CollisionData collisionData,
);

typedef ReflectionResolutionCallback = Vector2? Function(
  PositionComponent other,
  CollisionData data,
);

class CollisionApi {
  final Movement comp;
  CollisionApi(this.comp);
  BodyType bodyType = BodyType.dynamic;
  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;
  final Map<WithCollision, CollisionData> _collisionsResolution = {};
  CollisionData? _lastCollisionData;
  CollisionData? get lastCollisionData => _lastCollisionData;

  final List<BlockMovementCallback> _blockMovementCallbacks = [];
  final List<MovementBlockedCallback> _movementBlockedCallbacks = [];
  final List<ReflectionResolutionCallback> _reflectionResolutionCallbacks = [];

  void enable() => _isEnabled = true;
  void disable() => _isEnabled = false;

  void onBlockMovementListener(BlockMovementCallback callback) {
    _blockMovementCallbacks.add(callback);
  }

  void onMovementBlockedListener(MovementBlockedCallback callback) {
    _movementBlockedCallbacks.add(callback);
  }

  void reflectionResolution(ReflectionResolutionCallback callback) {
    _reflectionResolutionCallbacks.add(callback);
  }

  void dispose() {
    _blockMovementCallbacks.clear();
    _movementBlockedCallbacks.clear();
    _reflectionResolutionCallbacks.clear();
  }

  bool blockMovementHandle(
    Set<Vector2> intersectionPoints,
    GameComponent other,
  ) {
    for (final callback in _blockMovementCallbacks) {
      if (!callback(intersectionPoints, other)) {
        return false;
      }
    }
    return true;
  }

  void setCollisionResolution(
    WithCollision other,
    CollisionData data,
  ) {
    _collisionsResolution[other] = data;
  }

  void _onMovementBlocked(
    PositionComponent other,
    CollisionData collisionData,
  ) {
    _lastCollisionData = collisionData;

    if (bodyType.isDynamic) {
      Vector2 correction;
      var depth = collisionData.depth.abs();
      if (depth > 0) {
        depth += 0.08;
      }

      correction = -collisionData.normal * depth;
      if ((other is WithCollision) && other.collision.bodyType.isDynamic) {
        correction = -collisionData.normal * depth / 2;
      }

      comp.position += correction;
    }
    comp.velocity -= _getVelocityReflection(other, collisionData);

    for (final callback in _movementBlockedCallbacks) {
      callback(other, collisionData);
    }
  }

  Vector2 _getVelocityReflection(
    PositionComponent other,
    CollisionData data,
  ) {
    for (final callback in _reflectionResolutionCallbacks) {
      final result = callback(other, data);
      if (result != null) {
        return result;
      }
    }
    if (bodyType.isStatic) {
      return comp.absoluteCenter;
    }
    return data.normal * comp.velocity.dot(data.normal);
  }

  void onCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Sensor || !_isEnabled) {
      return;
    }
    var stopOtherMovement = true;
    final stopMovement = other is GameComponent
        ? blockMovementHandle(intersectionPoints, other)
        : true;
    if (other is WithCollision) {
      stopOtherMovement = other.collision.blockMovementHandle(
        intersectionPoints,
        comp,
      );
    }

    if (!stopMovement || !stopOtherMovement) {
      return;
    }

    if (_collisionsResolution.containsKey(other)) {
      _onMovementBlocked(
        other,
        _collisionsResolution[other]!,
      );
      _collisionsResolution.remove(other);
      return;
    }

    final shape1 = PolygonsIntersectUtil.getCollisionShapeHitbox(
      comp.shapeHitboxes,
      intersectionPoints,
    );
    final shape2 = PolygonsIntersectUtil.getCollisionShapeHitbox(
      other.children.query<ShapeHitbox>(),
      intersectionPoints,
    );

    if (shape1 == null || shape2 == null) {
      return;
    }

    ({Vector2 normal, double depth})? colisionResult;

    if (_isPolygon(shape1)) {
      if (_isPolygon(shape2)) {
        colisionResult = PolygonsIntersectUtil.intersectPolygons(
          shape1,
          shape2,
          other,
        );
      } else if (shape2 is CircleHitbox) {
        colisionResult = PolygonsIntersectUtil.intersectCirclePolygon(
          shape1,
          shape2,
          other,
        );
      }
    } else if (shape1 is CircleHitbox) {
      if (_isPolygon(shape2)) {
        colisionResult = PolygonsIntersectUtil.intersectCirclePolygon(
          shape2,
          shape1,
          other,
          inverted: true,
        );
      } else if (shape2 is CircleHitbox) {
        colisionResult = PolygonsIntersectUtil.intersectCircles(shape1, shape2);
      }
    }

    if (colisionResult != null) {
      final data = CollisionData(
        normal: colisionResult.normal,
        depth: colisionResult.depth,
        intersectionPoints: intersectionPoints.toList(),
        direction: colisionResult.normal.toDirection(),
      );
      _onMovementBlocked(other, data);
      if (other is WithCollision) {
        other.collision.setCollisionResolution(
          comp as WithCollision,
          data.inverted(),
        );
      }
    }
  }

  bool _isPolygon(ShapeHitbox shape) {
    return shape is RectangleHitbox || shape is PolygonHitbox;
  }
}
