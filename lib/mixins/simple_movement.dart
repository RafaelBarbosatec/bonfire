import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Ultra-simplified movement mixin - focuses on essentials only
///
/// This replaces the complex Movement mixin with a minimal, clean approach:
/// - Basic velocity-based movement
/// - Cardinal directions (up, down, left, right)
/// - Simple stop/start mechanics
/// - Direction tracking
/// - Extensible for advanced cases
mixin SimpleMovement on GameComponent {
  static const double defaultSpeed = 80.0;

  double speed = defaultSpeed;
  Vector2 _velocity = Vector2.zero();
  Direction direction = Direction.right;

  // Essential getters
  Vector2 get velocity => _velocity;
  bool get isMoving => !_velocity.isZero();
  bool get isIdle => _velocity.isZero();

  // Velocity control
  set velocity(Vector2 newVelocity) {
    _velocity = newVelocity;
    if (!newVelocity.isZero()) {
      direction = _getDirectionFromVelocity(newVelocity);
    }
  }

  // Basic cardinal movements - covers 90% of use cases
  void moveUp({double? speed}) {
    final moveSpeed = speed ?? this.speed;
    velocity = Vector2(0, -moveSpeed);
  }

  void moveDown({double? speed}) {
    final moveSpeed = speed ?? this.speed;
    velocity = Vector2(0, moveSpeed);
  }

  void moveLeft({double? speed}) {
    final moveSpeed = speed ?? this.speed;
    velocity = Vector2(-moveSpeed, 0);
  }

  void moveRight({double? speed}) {
    final moveSpeed = speed ?? this.speed;
    velocity = Vector2(moveSpeed, 0);
  }

  // Stop movement
  void stop() {
    velocity = Vector2.zero();
  }

  // Advanced: move by angle (for custom directions, pathfinding, etc.)
  void moveInDirection(double angleRadians, {double? speed}) {
    final moveSpeed = speed ?? this.speed;
    velocity = Vector2(
      cos(angleRadians) * moveSpeed,
      sin(angleRadians) * moveSpeed,
    );
  }

  // Advanced: move toward a target position (optional helper)
  void moveToward(Vector2 target, {double? speed}) {
    final direction = (target - position).normalized();
    final moveSpeed = speed ?? this.speed;
    velocity = direction * moveSpeed;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply movement
    if (!velocity.isZero()) {
      position += velocity * dt;
      onMove(); // Optional callback
    }
  }

  // Simple direction calculation from velocity
  Direction _getDirectionFromVelocity(Vector2 vel) {
    if (vel.x.abs() > vel.y.abs()) {
      return vel.x > 0 ? Direction.right : Direction.left;
    } else {
      return vel.y > 0 ? Direction.down : Direction.up;
    }
  }

  // Optional callback - override if you need movement events
  void onMove() {}
}

/// Extension methods for even simpler usage
extension SimpleMovementHelpers on SimpleMovement {
  static const double diagonalFactor = 0.7071; // 1/sqrt(2)
  // Diagonal movements (for those who need them)
  void moveUpRight({double? speed}) {
    final moveSpeed =
        (speed ?? this.speed) * diagonalFactor; // Normalize diagonal
    velocity = Vector2(moveSpeed, -moveSpeed);
  }

  void moveUpLeft({double? speed}) {
    final moveSpeed = (speed ?? this.speed) * diagonalFactor;
    velocity = Vector2(-moveSpeed, -moveSpeed);
  }

  void moveDownRight({double? speed}) {
    final moveSpeed = (speed ?? this.speed) * diagonalFactor;
    velocity = Vector2(moveSpeed, moveSpeed);
  }

  void moveDownLeft({double? speed}) {
    final moveSpeed = (speed ?? this.speed) * diagonalFactor;
    velocity = Vector2(-moveSpeed, moveSpeed);
  }

  // Move from Direction enum
  void moveFromDirection(Direction direction, {double? speed}) {
    switch (direction) {
      case Direction.up:
        moveUp(speed: speed);
        break;
      case Direction.down:
        moveDown(speed: speed);
        break;
      case Direction.left:
        moveLeft(speed: speed);
        break;
      case Direction.right:
        moveRight(speed: speed);
        break;
      case Direction.upLeft:
        moveUpLeft(speed: speed);
        break;
      case Direction.upRight:
        moveUpRight(speed: speed);
        break;
      case Direction.downLeft:
        moveDownLeft(speed: speed);
        break;
      case Direction.downRight:
        moveDownRight(speed: speed);
        break;
    }
  }
}
