import 'package:bonfire/collision/elastic_collision_api.dart';

/// Extension for common bounce patterns
extension BounceBehaviors on ElasticCollisionApi {
  /// Make object bounce eternally (near-perfect elasticity)
  void makeEternalBounce() {
    setup(
      bounciness: 0.99,
      minBounceVelocity: 5.0,
    );
  }

  /// Make object bounce like a rubber ball
  void makeRubberBall() {
    setup(
      bounciness: 0.9,
      minBounceVelocity: 10.0,
    );
  }

  /// Make object bounce like a basketball
  void makeBasketball() {
    setup(
      bounciness: 0.75,
      minBounceVelocity: 15.0,
    );
  }

  /// Make object bounce like a ping pong ball
  void makePingPongBall() {
    setup(
      bounciness: 0.95,
      minBounceVelocity: 8.0,
    );
  }

  /// Make object bounce and gradually lose energy (like a dropped ball)
  void makeDroppedBall() {
    setup(
      bounciness: 0.6,
      minBounceVelocity: 12.0,
    );
  }

  /// Make object barely bounce (like a heavy object)
  void makeHeavyObject() {
    setup(
      bounciness: 0.3,
      minBounceVelocity: 25.0,
    );
  }
}
