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
      final otherVelocity =
          (other is Movement) ? other.velocity : Vector2.zero();
      final relativeVelocity = otherVelocity - velocity;

      if (relativeVelocity.dot(data.normal) > 0) {
        return super.getVelocityReflection(other, data);
      }

      final bRestitution =
          (other is ElasticCollision) ? other._restitution : _restitution;

      final double e = min(_restitution, bRestitution);

      var j = -(1 + e) * relativeVelocity.dot(data.normal);

      final mass = (this is HandleForces) ? (this as HandleForces).mass : 1;
      final massB = (other is HandleForces) ? other.mass : 1;
      j /= mass + massB;

      final impulse = data.normal * j;
      return impulse;
    }
    return super.getVelocityReflection(other, data);
  }
}
