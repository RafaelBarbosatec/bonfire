import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Simple elastic collision system for bouncy objects
///
/// This mixin adds realistic bounce behavior to components using SimpleCollision.
/// It's much simpler and more predictable than the original ElasticCollision.
mixin SimpleElasticCollision on SimpleCollision {
  static const double baseRestitution = 3.0; // Default restitution value
  double _restitution = baseRestitution;
  bool _bouncingObjectEnabled = true;
  double bounciness = 0.8;
  double _minBounceVelocity = 0.0; // Minimum velocity to bounce

  void setupElasticCollision({
    bool? enabled,
    double? bounciness,
    double? minBounceVelocity,
  }) {
    _bouncingObjectEnabled = enabled ?? _bouncingObjectEnabled;
    _minBounceVelocity = minBounceVelocity ?? _minBounceVelocity;
    this.bounciness = (bounciness ?? this.bounciness).clamp(0.0, 1.0);
    _restitution = this.bounciness * baseRestitution;
  }

  // source https://chrishecker.com/images/e/e7/Gdmphys3.pdf
  // Applying Impulse
  @override
  Vector2 getVelocityReflection(
    PositionComponent other,
    CollisionData data,
  ) {
    if (_bouncingObjectEnabled) {
      if (velocity.length < _minBounceVelocity) {
        return super.getVelocityReflection(other, data);
      }
      final otherVelocity =
          (other is Movement) ? other.velocity : Vector2.zero();
      final relativeVelocity = otherVelocity - velocity;

      if (relativeVelocity.dot(data.normal) > 0) {
        return super.getVelocityReflection(other, data);
      }

      final bRestitution =
          (other is SimpleElasticCollision) ? other._restitution : _restitution;

      final double e = min(_restitution, bRestitution);

      var j = -(1 + e) * relativeVelocity.dot(data.normal);

      final mass = (this is HandleForces) ? (this as HandleForces).mass : 1;
      final massB = (other is HandleForces) ? other.mass : 1;
      j /= mass + massB;

      final impulse = data.normal * j;

      onBounce(other, data, impulse);

      return impulse;
    }
    return super.getVelocityReflection(other, data);
  }

  void stopBouncing() {
    _bouncingObjectEnabled = false;
  }

  void onBounce(
    PositionComponent other,
    CollisionData data,
    Vector2 bounceVel,
  ) {}
}

/// Extension for common bounce patterns
extension BounceBehaviors on SimpleElasticCollision {
  /// Make object bounce like a rubber ball
  void makeRubberBall() {
    setupElasticCollision(
      enabled: true,
      bounciness: 0.9,
      minBounceVelocity: 5.0,
    );
  }

  /// Make object bounce like a basketball
  void makeBasketball() {
    setupElasticCollision(
      enabled: true,
      bounciness: 0.7,
      minBounceVelocity: 15.0,
    );
  }

  /// Make object bounce like a ping pong ball
  void makePingPongBall() {
    setupElasticCollision(
      enabled: true,
      bounciness: 0.95,
      minBounceVelocity: 3.0,
    );
  }

  /// Make object bounce and gradually lose energy (like a dropped ball)
  void makeDroppedBall() {
    setupElasticCollision(
      enabled: true,
      bounciness: 0.6,
      minBounceVelocity: 8.0,
    );
  }

  /// Make object barely bounce (like a heavy object)
  void makeHeavyObject() {
    setupElasticCollision(
      enabled: true,
      bounciness: 0.2,
      minBounceVelocity: 20.0,
    );
  }
}
