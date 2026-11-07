import 'dart:math' as math;

import 'package:bonfire/base/game_component.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/widgets.dart' show Offset, Rect;

/// A polygon that blocks light, in **world coordinates**.
///
/// Register occluders once for tile maps:
///
/// ```dart
/// for (final tile in wallTiles) {
///   gameRef.lighting.addOccluder(
///     LightingOccluder.rect(tile.toRect()),
///   );
/// }
/// ```
///
/// and mark the lights that should respect them with
/// `LightingConfig(castShadows: true)`.
///
/// For moving obstacles prefer [WithLightingOcclusion], so the occluder follows
/// the component.
class LightingOccluder {
  /// Vertices of the polygon, in world coordinates. The polygon is closed
  /// automatically (the last point connects to the first one).
  final List<Vector2> points;

  /// Axis aligned bounds of [points]. Used to quickly discard occluders that
  /// are out of the light radius.
  final Rect bounds;

  /// Creates an occluder from a world space polygon.
  factory LightingOccluder(List<Vector2> points) {
    assert(points.length >= 3, 'An occluder needs at least 3 points');
    final copy = List<Vector2>.unmodifiable(
      points.map((point) => point.clone()).toList(growable: false),
    );

    var minX = copy.first.x;
    var minY = copy.first.y;
    var maxX = copy.first.x;
    var maxY = copy.first.y;
    for (final point in copy) {
      minX = math.min(minX, point.x);
      minY = math.min(minY, point.y);
      maxX = math.max(maxX, point.x);
      maxY = math.max(maxY, point.y);
    }

    return LightingOccluder._(copy, Rect.fromLTRB(minX, minY, maxX, maxY));
  }

  LightingOccluder._(this.points, this.bounds);

  /// Creates a rectangular occluder from a world space [rect].
  factory LightingOccluder.rect(Rect rect) {
    return LightingOccluder([
      Vector2(rect.left, rect.top),
      Vector2(rect.right, rect.top),
      Vector2(rect.right, rect.bottom),
      Vector2(rect.left, rect.bottom),
    ]);
  }

  /// Creates a rectangular occluder centered on [center].
  factory LightingOccluder.centered(Vector2 center, Vector2 size) {
    return LightingOccluder.rect(
      Rect.fromCenter(
        center: Offset(center.x, center.y),
        width: size.x,
        height: size.y,
      ),
    );
  }
}

/// Mixin for components that should block light where they are.
///
/// The occluders are read every frame in world coordinates, so they can move
/// with the component:
///
/// ```dart
/// class Pillar extends GameDecoration with WithLightingOcclusion {
///   @override
///   List<LightingOccluder> get lightingOccluders => [
///         LightingOccluder.rect(toAbsoluteRect()),
///       ];
/// }
/// ```
///
/// Only components added directly to the game world are considered (the same
/// rule used by `WithLighting`).
mixin WithLightingOcclusion on GameComponent {
  /// Occluders produced by this component, in world coordinates.
  List<LightingOccluder> get lightingOccluders;
}

/// Computes the region visible from [center], limited by [radius] and clipped
/// by [occluders].
///
/// The result is a polygon whose points are ordered by angle. Returns an empty
/// list when [radius] is not positive or when [center] is inside an occluder
/// (the light is completely hidden).
///
/// [rays] is the number of evenly spaced rays added to the rays that target the
/// corners of every occluder. Corners are always sampled, so even a low number
/// of rays keeps the silhouette recognizable.
List<Vector2> computeVisibilityPolygon({
  required Vector2 center,
  required double radius,
  required List<LightingOccluder> occluders,
  int rays = 64,
}) {
  if (radius <= 0) {
    return const [];
  }

  final segments = <_Segment>[];
  for (final occluder in occluders) {
    if (_distanceToRect(center, occluder.bounds) > radius) {
      continue;
    }
    final points = occluder.points;
    for (var i = 0; i < points.length; i++) {
      segments.add(_Segment(points[i], points[(i + 1) % points.length]));
    }
  }

  // A light inside a wall is fully blocked.
  for (final occluder in occluders) {
    if (occluder.bounds.contains(center.toOffset()) &&
        pointInPolygon(center, occluder.points)) {
      return const [];
    }
  }

  if (segments.isEmpty) {
    return _circlePolygon(center, radius, rays);
  }

  final angles = <double>[];

  final rayCount = math.max(8, rays);
  for (var i = 0; i < rayCount; i++) {
    angles.add((i / rayCount) * math.pi * 2);
  }

  // Besides the evenly spaced rays, aim at both ends of every segment. The
  // small offsets avoid missing a corner when two rays are nearly parallel.
  for (final segment in segments) {
    for (final point in [segment.a, segment.b]) {
      final angle = math.atan2(point.y - center.y, point.x - center.x);
      angles
        ..add(angle - _cornerEpsilon)
        ..add(angle)
        ..add(angle + _cornerEpsilon);
    }
  }

  angles.sort();

  final result = <Vector2>[];
  for (final angle in angles) {
    final direction = Vector2(math.cos(angle), math.sin(angle));
    var distance = radius;

    for (final segment in segments) {
      final hit = _rayHit(center, direction, segment);
      if (hit != null && hit > _minDistance && hit < distance) {
        distance = hit;
      }
    }

    result.add(center + direction * distance);
  }

  return result;
}

/// Whether [point] is inside the polygon defined by [polygon].
///
/// Uses the even-odd rule, so it works with concave polygons as well.
bool pointInPolygon(Vector2 point, List<Vector2> polygon) {
  if (polygon.length < 3) {
    return false;
  }

  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final xi = polygon[i].x;
    final yi = polygon[i].y;
    final xj = polygon[j].x;
    final yj = polygon[j].y;

    final intersects = (yi > point.y) != (yj > point.y) &&
        point.x < (xj - xi) * (point.y - yi) / (yj - yi) + xi;
    if (intersects) {
      inside = !inside;
    }
  }
  return inside;
}

const double _cornerEpsilon = 0.0002;
const double _minDistance = 0.001;

List<Vector2> _circlePolygon(Vector2 center, double radius, int rays) {
  final count = math.max(8, rays);
  return List<Vector2>.generate(
    count,
    (index) {
      final angle = (index / count) * math.pi * 2;
      return center + Vector2(math.cos(angle), math.sin(angle)) * radius;
    },
    growable: false,
  );
}

double _distanceToRect(Vector2 point, Rect rect) {
  final dx = math.max(math.max(rect.left - point.x, 0.0), point.x - rect.right);
  final dy = math.max(math.max(rect.top - point.y, 0.0), point.y - rect.bottom);
  return math.sqrt(dx * dx + dy * dy);
}

/// Returns the distance from [origin] to the intersection with [segment],
/// or `null` when the ray does not hit it.
double? _rayHit(Vector2 origin, Vector2 direction, _Segment segment) {
  final segmentX = segment.b.x - segment.a.x;
  final segmentY = segment.b.y - segment.a.y;

  final denominator = direction.x * segmentY - direction.y * segmentX;
  if (denominator.abs() < 1e-9) {
    return null;
  }

  final originToA = segment.a - origin;
  final distance =
      (originToA.x * segmentY - originToA.y * segmentX) / denominator;
  final segmentPosition =
      (originToA.x * direction.y - originToA.y * direction.x) / denominator;

  if (distance <= 0 || segmentPosition < -1e-9 || segmentPosition > 1 + 1e-9) {
    return null;
  }
  return distance;
}

class _Segment {
  final Vector2 a;
  final Vector2 b;

  const _Segment(this.a, this.b);
}
