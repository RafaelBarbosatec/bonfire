import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Examples of using SimpleElasticCollision

// Example 1: Bouncy ball that bounces around
class BouncyBall extends GameComponent
    with
        SimpleMovement,
        SimpleCollision,
        SimpleElasticCollision,
        HasCollisionDetection {
  BouncyBall({required Vector2 position, required Vector2 initialVelocity}) {
    this.position = position;
    add(CircleHitbox(radius: 16));

    // Setup as dynamic body with elastic collision
    setupCollision(bodyType: BodyType.dynamic);
    makeRubberBall(); // Predefined bounce behavior

    // Set initial velocity
    velocity = initialVelocity;
  }

  @override
  void onBounce(
    PositionComponent other,
    CollisionData data,
    Vector2 bounceVel,
  ) {
    super.onBounce(other, data, bounceVel);

    // Add visual/audio effects
    print('Ball bounced with velocity: ${bounceVel.length.toStringAsFixed(1)}');

    // Could add: particle effects, sound, screen shake, etc.
    // gameRef.camera.shake(intensity: bounceVel.length * 0.01);
  }
}

// Example 2: Basketball that loses energy over time
class Basketball extends GameComponent
    with
        SimpleMovement,
        SimpleCollision,
        SimpleElasticCollision,
        HasCollisionDetection {
  Basketball({required Vector2 position}) {
    this.position = position;
    add(CircleHitbox(radius: 20));

    setupCollision(bodyType: BodyType.dynamic);
    makeBasketball(); // 70% bounce, realistic for basketball

    // Add gravity effect (you could use HandleForces for this)
    velocity = Vector2(0, 50); // Initial downward velocity
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Simple gravity simulation
    velocity.y += 300 * dt; // Gravity acceleration
  }

  @override
  void onBounce(
    PositionComponent other,
    CollisionData data,
    Vector2 bounceVel,
  ) {
    super.onBounce(other, data, bounceVel);

    // Basketball-specific effects
    if (data.direction == Direction.up) {
      print('Basketball bounced off the ground!');
    }
  }
}

// Example 3: Ping pong ball with high bounce
class PingPongBall extends GameComponent
    with
        SimpleMovement,
        SimpleCollision,
        SimpleElasticCollision,
        HasCollisionDetection {
  PingPongBall({required Vector2 position}) {
    this.position = position;
    add(CircleHitbox(radius: 8));

    setupCollision(bodyType: BodyType.dynamic);
    makePingPongBall(); // Very high bounce (95%)

    velocity = Vector2(120, -80); // Fast initial velocity
  }
}

// Example 4: Heavy crate that barely bounces
class HeavyCrate extends GameComponent
    with
        SimpleMovement,
        SimpleCollision,
        SimpleElasticCollision,
        HasCollisionDetection {
  HeavyCrate({required Vector2 position}) {
    this.position = position;
    add(RectangleHitbox(size: Vector2(40, 40)));

    setupCollision(bodyType: BodyType.dynamic);
    makeHeavyObject(); // Low bounce (20%), high min velocity

    velocity = Vector2(60, 0);
  }

  @override
  void onBounce(
    PositionComponent other,
    CollisionData data,
    Vector2 bounceVel,
  ) {
    super.onBounce(other, data, bounceVel);

    // Heavy objects make more impact
    print('THUD! Heavy crate bounced with force: ${bounceVel.length}');
  }
}

// Example 5: Custom bounce behavior
class CustomBouncyObject extends GameComponent
    with
        SimpleMovement,
        SimpleCollision,
        SimpleElasticCollision,
        HasCollisionDetection {
  int bounceCount = 0;

  CustomBouncyObject({required Vector2 position}) {
    this.position = position;
    add(RectangleHitbox(size: Vector2(24, 24)));

    setupCollision(bodyType: BodyType.dynamic);

    // Custom elastic setup
    setupElasticCollision(
      enabled: true,
      bounciness: 0.8,
      minBounceVelocity: 5.0,
    );

    velocity = Vector2(80, -60);
  }

  @override
  void onBounce(
    PositionComponent other,
    CollisionData data,
    Vector2 bounceVel,
  ) {
    super.onBounce(other, data, bounceVel);

    bounceCount++;

    // Reduce bounciness over time
    if (bounceCount > 5) {
      setupElasticCollision(
        enabled: true,
        bounciness: max(0.1, bounciness - 0.1),
      );
    }

    // Stop bouncing after many bounces
    if (bounceCount > 15) {
      stopBouncing();
    }
  }
}

// Example 6: Paddle that doesn't bounce (static wall)
class Paddle extends GameComponent
    with SimpleMovement, SimpleCollision, HasCollisionDetection {
  Paddle({required Vector2 position}) {
    this.position = position;
    add(RectangleHitbox(size: Vector2(100, 20)));

    // Static body - doesn't move when hit
    setupCollision(bodyType: BodyType.static);
  }

  void movePaddleLeft() => position.x -= 5;
  void movePaddleRight() => position.x += 5;
}

// Example 7: Trampoline that adds extra bounce
class Trampoline extends GameComponent
    with SimpleMovement, SimpleCollision, HasCollisionDetection {
  Trampoline({required Vector2 position}) {
    this.position = position;
    add(RectangleHitbox(size: Vector2(80, 16)));
    setupCollision(bodyType: BodyType.static);
  }

  @override
  bool onBlockMovement(Set<Vector2> points, GameComponent other) {
    // Give extra bounce to elastic objects
    if (other is SimpleElasticCollision) {
      // Add extra upward velocity (trampoline effect)
      final movementComponent = other as SimpleMovement;
      movementComponent.velocity = Vector2(
        movementComponent.velocity.x,
        movementComponent.velocity.y - 200, // Extra bounce!
      );
    }
    return true;
  }
}

// Example 8: Breakout-style game setup
class BreakoutGame extends GameComponent {
  void setupBreakoutGame() {
    // Ball
    final ball = BouncyBall(
      position: Vector2(400, 300),
      initialVelocity: Vector2(150, -200),
    );
    add(ball);

    // Paddle
    final paddle = Paddle(position: Vector2(350, 550));
    add(paddle);

    // Walls (static, non-elastic)
    add(Wall(position: Vector2(0, 0), size: Vector2(800, 20))); // Top
    add(Wall(position: Vector2(0, 0), size: Vector2(20, 600))); // Left
    add(Wall(position: Vector2(780, 0), size: Vector2(20, 600))); // Right

    // Bricks (could be made bouncy or not)
    for (var x = 0; x < 10; x++) {
      for (var y = 0; y < 5; y++) {
        add(Brick(position: Vector2(80.0 + x * 64, 100.0 + y * 24)));
      }
    }
  }
}

class Wall extends GameComponent
    with SimpleMovement, SimpleCollision, HasCollisionDetection {
  Wall({required Vector2 position, required Vector2 size}) {
    this.position = position;
    add(RectangleHitbox(size: size));
    setupCollision(bodyType: BodyType.static);
  }
}

class Brick extends GameComponent
    with SimpleMovement, SimpleCollision, HasCollisionDetection {
  Brick({required Vector2 position}) {
    this.position = position;
    add(RectangleHitbox(size: Vector2(60, 20)));
    setupCollision(bodyType: BodyType.static);
  }

  @override
  void onMovementBlocked(PositionComponent other, CollisionData data) {
    super.onMovementBlocked(other, data);

    // Destroy brick when hit by ball
    if (other is BouncyBall) {
      removeFromParent();
    }
  }
}

/// Usage Summary:

/// Basic bouncy object:
/// ```dart
/// class MyBall extends GameComponent 
///     with SimpleMovement, SimpleCollision, SimpleElasticCollision, HasCollisionDetection {
///   
///   MyBall() {
///     add(CircleHitbox(radius: 16));
///     setupCollision(bodyType: BodyType.dynamic);
///     makeRubberBall(); // Easy setup!
///   }
/// }
/// ```

/// Custom bounce settings:
/// ```dart
/// setupElasticCollision(
///   enabled: true,
///   bounciness: 0.8,        // 80% energy retained
///   minBounceVelocity: 10.0, // Don't bounce if moving too slow
/// );
/// ```

/// Predefined behaviors:
/// - `makeRubberBall()` - High bounce, low min velocity
/// - `makeBasketball()` - Medium bounce, realistic
/// - `makePingPongBall()` - Very high bounce
/// - `makeDroppedBall()` - Gradual energy loss
/// - `makeHeavyObject()` - Low bounce, high threshold