import 'package:bonfire/bonfire.dart';

class CollisionData {
  final Vector2 normal;
  final double depth;
  final List<Vector2> intersectionPoints;
  final Direction direction;

  CollisionData({
    required this.normal,
    required this.depth,
    required this.direction,
    required this.intersectionPoints,
  });

  CollisionData copyWith({
    Vector2? normal,
    double? depth,
    Direction? direction,
    List<Vector2>? intersectionPoints,
  }) {
    return CollisionData(
      normal: normal ?? this.normal,
      depth: depth ?? this.depth,
      direction: direction ?? this.direction,
      intersectionPoints: intersectionPoints ?? this.intersectionPoints,
    );
  }

  CollisionData inverted() {
    return CollisionData(
      normal: -normal,
      depth: depth,
      direction: (-normal).toDirection(),
      intersectionPoints: intersectionPoints,
    );
  }
}
