import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';

/// Performs Quad Tree broadphase check.
///
/// See [HasQuadTreeCollisionDetection.initializeCollisionDetection] for a
/// detailed description of its initialization parameters.
class CustomQuadTreeBroadphase extends QuadTreeBroadphase {
  CustomQuadTreeBroadphase({
    required super.mainBoxSize,
    required super.broadphaseCheck,
    required super.minimumDistanceCheck,
    super.maxDepth,
    super.maxObjects,
  });

  final _broadphaseCheckCache = <ShapeHitbox, Map<ShapeHitbox, bool>>{};

  final _cachedCenters = <ShapeHitbox, Vector2>{};

  final _potentials = <int, CollisionProspect<ShapeHitbox>>{};
  final _potentialsTmp = <ShapeHitbox>[];
  final _prospectPool = ProspectPool<ShapeHitbox>();

  @override
  Iterable<CollisionProspect<ShapeHitbox>> query() {
    _potentials.clear();
    _potentialsTmp.clear();

    for (final activeItem in activeHitboxes) {
      if (activeItem.isRemoving || !activeItem.isMounted) {
        tree.remove(activeItem);
        continue;
      }

      final itemCenter = activeItem.aabb.center;
      final potentiallyCollide = tree.query(activeItem);
      for (final potential in potentiallyCollide.entries.first.value) {
        if (potential.collisionType == CollisionType.inactive) {
          continue;
        }

        if (_broadphaseCheckCache[activeItem]?[potential] == false) {
          continue;
        }

        if (!potential.allowSiblingCollision &&
            potential.hitboxParent == activeItem.hitboxParent &&
            potential.isMounted) {
          continue;
        }

        final distanceCloseEnough = minimumDistanceCheck.call(
          itemCenter,
          _cacheCenterOfHitbox(potential),
        );
        if (distanceCloseEnough == false) {
          continue;
        }

        _potentialsTmp
          ..add(activeItem)
          ..add(potential);
      }
    }

    if (_potentialsTmp.isNotEmpty) {
      for (var i = 0; i < _potentialsTmp.length; i += 2) {
        final item0 = _potentialsTmp[i];
        final item1 = _potentialsTmp[i + 1];
        if (broadphaseCheck(item0, item1)) {
          final CollisionProspect<ShapeHitbox> prospect;
          while (_prospectPool.length <= i) {
            _prospectPool.expand(item0);
          }
          prospect = _prospectPool[i]..set(item0, item1);
          _potentials[prospect.hash] = prospect;
        } else {
          if (_broadphaseCheckCache[item0] == null) {
            _broadphaseCheckCache[item0] = {};
          }
          _broadphaseCheckCache[item0]![item1] = false;
        }
      }
    }
    return _potentials.values;
  }

  /// Caches hitbox center because calculating on-the-fly is too expensive
  /// whereas many of game objects could not change theirs position or size
  Vector2 _cacheCenterOfHitbox(ShapeHitbox hitbox) {
    var cache = _cachedCenters[hitbox];
    if (cache == null) {
      _cachedCenters[hitbox] = hitbox.aabb.center;
      cache = _cachedCenters[hitbox];
    }
    return cache!;
  }
}
