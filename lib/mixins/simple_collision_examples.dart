import 'package:bonfire/bonfire.dart' hide BodyType;
import 'package:bonfire/mixins/simple_collision.dart';
import 'package:bonfire/mixins/simple_movement.dart';
import 'package:flutter/services.dart';

/// Examples of using SimpleCollision with SimpleMovement

// Example 1: Basic collision-aware component
class CollidingComponent extends GameComponent
    with SimpleMovement, SimpleCollision, HasCollisionDetection {
  CollidingComponent({required Vector2 position, required Vector2 size}) {
    this.position = position;
    add(RectangleHitbox(size: size));

    // Setup collision as dynamic body (can be pushed)
    setupCollision(
      enabled: true,
      bodyType: BodyType.dynamic,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Simple AI movement - will be blocked by collisions
    if (position.x < 100) {
      moveRight();
    } else if (position.x > 200) {
      moveLeft();
    }
  }

  @override
  void onMovementBlocked(PositionComponent other, CollisionData collisionData) {
    super.onMovementBlocked(other, collisionData);

    // Custom behavior when blocked
    print(
        'Collision with ${other.runtimeType} from ${collisionData.direction}');

    // Maybe change direction when hitting a wall
    if (collisionData.direction == Direction.right) {
      moveUp();
    } else if (collisionData.direction == Direction.left) {
      moveDown();
    }
  }
}

// Example 2: Player with collision
class PlayerWithCollision extends GameComponent
    with SimpleMovement, SimpleCollision, HasCollisionDetection {
  PlayerWithCollision({required Vector2 position}) {
    this.position = position;
    add(RectangleHitbox(size: Vector2(32, 32)));
    setupCollision(bodyType: BodyType.dynamic);
  }

  void handleInput(Set<LogicalKeyboardKey> keys) {
    // Movement will automatically be blocked by collisions
    stop(); // Reset movement

    if (keys.contains(LogicalKeyboardKey.arrowUp)) moveUp();
    if (keys.contains(LogicalKeyboardKey.arrowDown)) moveDown();
    if (keys.contains(LogicalKeyboardKey.arrowLeft)) moveLeft();
    if (keys.contains(LogicalKeyboardKey.arrowRight)) moveRight();
  }
}

// Example 3: Static wall/obstacle
class Wall extends GameComponent
    with SimpleMovement, SimpleCollision, HasCollisionDetection {
  Wall({required Vector2 position, required Vector2 size}) {
    this.position = position;
    add(RectangleHitbox(size: size));

    // Static bodies don't move when hit
    setupCollision(bodyType: BodyType.static);
  }

  // Walls don't need movement, but SimpleMovement is required for SimpleCollision
}

// Example 4: Sensor (doesn't block movement)
class TriggerArea extends GameComponent
    with SimpleMovement, SimpleCollision, HasCollisionDetection {
  TriggerArea({required Vector2 position, required Vector2 size}) {
    this.position = position;
    add(RectangleHitbox(size: size)); // Non-solid
  }

  @override
  bool shouldBlockMovement(
      Set<Vector2> intersectionPoints, GameComponent other) {
    // Don't block movement, just trigger events
    print('Player entered trigger area!');
    return false;
  }
}

// Example 5: One-way platform
class OneWayPlatform extends GameComponent
    with SimpleMovement, SimpleCollision, HasCollisionDetection {
  OneWayPlatform({required Vector2 position, required Vector2 size}) {
    this.position = position;
    add(RectangleHitbox(size: size));
    setupCollision(bodyType: BodyType.static);
  }

  @override
  bool shouldBlockMovement(
      Set<Vector2> intersectionPoints, GameComponent other) {
    // Only block if other component is coming from above
    if (other is SimpleMovement) {
      return other.velocity.y > 0; // Moving down
    }
    return true;
  }
}

// Example 6: Bouncy object
class BouncyBall extends GameComponent
    with SimpleMovement, SimpleCollision, HasCollisionDetection {
  BouncyBall({required Vector2 position}) {
    this.position = position;
    add(CircleHitbox(radius: 16));
    setupCollision(bodyType: BodyType.dynamic);

    // Start with some initial velocity
    velocity = Vector2(100, -150);
  }

  @override
  void onMovementBlocked(PositionComponent other, CollisionData collisionData) {
    super.onMovementBlocked(other, collisionData);

    // Bounce off surfaces
    final reflection = velocity -
        (collisionData.normal * (2 * velocity.dot(collisionData.normal)));
    velocity = reflection * 0.8; // Lose some energy
  }
}

/// Usage patterns:

/// Simple setup (most common):
/// ```dart
/// class MyComponent extends GameComponent 
///     with SimpleMovement, SimpleCollision, HasCollisionDetection {
///   
///   MyComponent() {
///     add(RectangleHitbox(size: Vector2(32, 32)));
///     setupCollision(); // Default: dynamic body, collision enabled
///   }
/// }
/// ```

/// Advanced setup:
/// ```dart
/// setupCollision(
///   enabled: true,           // Enable/disable collision
///   bodyType: BodyType.dynamic, // dynamic or static
/// );
/// ```

/// Custom collision behavior:
/// ```dart
/// @override
/// bool shouldBlockMovement(Set<Vector2> points, GameComponent other) {
///   // Return false to ignore this specific collision
///   return other is! Sensor;
/// }
/// 
/// @override
/// void onMovementBlocked(PositionComponent other, CollisionData data) {
///   super.onMovementBlocked(other, data);
///   // Custom logic when collision blocks movement
/// }
/// ```