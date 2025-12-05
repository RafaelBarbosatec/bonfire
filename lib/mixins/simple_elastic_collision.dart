import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/simple_collision.dart';

/// Simple elastic collision system for bouncy objects
///
/// This mixin adds realistic bounce behavior to components using SimpleCollision.
/// It's much simpler and more predictable than the original ElasticCollision.
mixin SimpleElasticCollision on SimpleCollision {
  double _bounciness = 0.8; // Energy retained after bounce (0.0 to 1.0)
  double _minBounceVelocity = 10.0; // Minimum velocity to bounce
  bool _elasticEnabled = true;

  // Public getters
  double get bounciness => _bounciness;
  double get minBounceVelocity => _minBounceVelocity;
  bool get elasticEnabled => _elasticEnabled;

  /// Setup elastic collision behavior
  void setupElasticCollision({
    bool? enabled,
    double? bounciness,
    double? minBounceVelocity,
  }) {
    _elasticEnabled = enabled ?? _elasticEnabled;
    _bounciness = (bounciness ?? _bounciness).clamp(0.0, 1.0);
    _minBounceVelocity = minBounceVelocity ?? _minBounceVelocity;
  }

  @override
  void onMovementBlocked(PositionComponent other, CollisionData collisionData) {
    if (!_elasticEnabled || bodyType.isStatic) {
      super.onMovementBlocked(other, collisionData);
      return;
    }

    // Store original velocity for bounce calculation
    final originalVelocity = velocity.clone();

    // Apply normal collision resolution first
    super.onMovementBlocked(other, collisionData);

    // Calculate and apply bounce
    _applyElasticBounce(originalVelocity, collisionData, other);
  }

  void _applyElasticBounce(
    Vector2 originalVelocity,
    CollisionData collisionData,
    PositionComponent other,
  ) {
    // Don't bounce if velocity is too low
    if (originalVelocity.length < _minBounceVelocity) {
      return;
    }

    // Calculate reflection
    final normal = collisionData.normal;
    final velocityIntoNormal = originalVelocity.dot(normal);

    // Only bounce if moving into the surface
    if (velocityIntoNormal >= 0) {
      return;
    }

    // Calculate bounce velocity using simple reflection
    final bounceVelocity = _calculateBounceVelocity(
      originalVelocity,
      normal,
      other,
    );

    // Apply bounced velocity
    velocity = bounceVelocity;

    // Optional callback for bounce effects
    onBounce(other, collisionData, bounceVelocity);
  }

  Vector2 _calculateBounceVelocity(
    Vector2 originalVelocity,
    Vector2 normal,
    PositionComponent other,
  ) {
    // Simple reflection formula: v' = v - 2(v·n)n
    final reflection =
        originalVelocity - (normal * (2 * originalVelocity.dot(normal)));

    // Apply bounciness factor
    var finalBounciness = _bounciness;

    // If other object is also elastic, combine bounciness
    if (other is SimpleElasticCollision) {
      finalBounciness = max(_bounciness, other._bounciness);
    }

    return reflection * finalBounciness;
  }

  /// Override this to add bounce effects (sound, particles, etc.)
  void onBounce(
    PositionComponent other,
    CollisionData collisionData,
    Vector2 bounceVelocity,
  ) {
    // Optional: Add particle effects, sound, screen shake, etc.
  }

  /// Convenience method to make object bouncy
  void makeBouncy({double bounciness = 0.8}) {
    setupElasticCollision(
      enabled: true,
      bounciness: bounciness,
    );
  }

  /// Convenience method to stop bouncing
  void stopBouncing() {
    setupElasticCollision(enabled: false);
  }

  /// Add spin effect to bounced objects
  void addSpinToBounce({double spinFactor = 0.1}) {
    // This could be extended to add angular velocity
    // For now, just a placeholder for future spin physics
  }
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
