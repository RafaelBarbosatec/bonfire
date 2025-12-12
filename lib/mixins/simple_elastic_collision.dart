import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Simple elastic collision system for bouncy objects
///
/// This mixin adds realistic bounce behavior to components using SimpleCollision.
/// It's much simpler and more predictable than the original ElasticCollision.
mixin SimpleElasticCollision on SimpleCollision {
  double restitution = 2;
  bool _bouncingObjectEnabled = true;

  void setupElasticCollision({
    bool? enabled,
    double? restitution,
  }) {
    _bouncingObjectEnabled = enabled ?? _bouncingObjectEnabled;
    restitution = restitution ?? this.restitution;
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
          (other is SimpleElasticCollision) ? other.restitution : restitution;

      final double e = min(restitution, bRestitution);

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
