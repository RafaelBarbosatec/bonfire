import 'dart:ui';

import 'package:bonfire/bonfire.dart';

abstract class Force2D {
  dynamic id;
  Vector2 value;
  Force2D({required this.id, required this.value});

  Vector2 transform(Vector2 velocity, double mass, double dt);
}

/// Apply acceleration to velocity
/// {value} pixel/seconds
class AccelerationForce2D extends Force2D {
  AccelerationForce2D({required super.id, required super.value});

  @override
  Vector2 transform(Vector2 velocity, double mass, double dt) {
    return velocity + (value * mass * dt);
  }
}

/// Apply resistence to velocity
/// {value} pixel/seconds
class ResistanceForce2D extends Force2D {
  ResistanceForce2D({required super.id, required super.value});

  @override
  Vector2 transform(Vector2 velocity, double mass, double dt) {
    return Vector2(
      lerpDouble(velocity.x, 0, dt * value.x) ?? 0,
      lerpDouble(velocity.y, 0, dt * value.y) ?? 0,
    );
  }
}

/// Apply linear force to velocity
class LinearForce2D extends Force2D {
  LinearForce2D({required super.id, required super.value});

  @override
  Vector2 transform(Vector2 velocity, double mass, double dt) {
    return Vector2(
      velocity.x < value.x ? value.x : velocity.x,
      velocity.y < value.y ? value.y : velocity.y,
    );
  }
}

/// Apply acceleration to velocity
/// {value} pixel/seconds
class GravityForce2D extends AccelerationForce2D {
  GravityForce2D({Vector2? value})
      : super(id: 'GravityForce2D', value: value ?? Vector2(0, 600));
}
