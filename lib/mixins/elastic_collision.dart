import 'dart:math';

import 'package:bonfire/bonfire.dart';

// Mixin responsable to give the bounce behavior. (experimental)
mixin ElasticCollision on BlockMovementCollision {
  double _restitution = 2;
  bool _bouncingObjectEnabled = true;

  void setupElasticCollision({
    bool? enabled,
    double? restitution,
  }) {
    _bouncingObjectEnabled = enabled ?? _bouncingObjectEnabled;
    _restitution = restitution ?? _restitution;
  }

  // source https://chrishecker.com/images/e/e7/Gdmphys3.pdf
  // Applying Impulse
  @override
  Vector2 getVelocityReflection(
    PositionComponent other,
    CollisionData data,
  ) {
    if (_bouncingObjectEnabled) {
      Vector2 otherVelocity =
          (other is Movement) ? other.velocity : Vector2.zero();
      Vector2 relativeVelocity = otherVelocity - velocity;

      if (relativeVelocity.dot(data.normal) > 0) {
        return super.getVelocityReflection(other, data);
      }

      double bRestitution =
          (other is ElasticCollision) ? other._restitution : _restitution;

      double e = min(_restitution, bRestitution);

      double j = -(1 + e) * relativeVelocity.dot(data.normal);

      double mass = (this is HandleForces) ? (this as HandleForces).mass : 1;
      double massB = (other is HandleForces) ? (other).mass : 1;
      j /= mass + massB;

      Vector2 impulse = data.normal * j;
      return impulse;
    }
    return super.getVelocityReflection(other, data);
  }
}
