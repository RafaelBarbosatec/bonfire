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
  void onMove() {
    _requestUpdatePriority();
  }

  void _requestUpdatePriority() {
    if (hasGameRef && direction.isVertical) {
      (gameRef as BonfireGame).requestUpdatePriority();
    }
  }
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

  /// Check if the component can move in the specified direction without collision
  ///
  /// This is an optimized version of the canMove function that:
  /// - Uses fewer raycasts for better performance
  /// - Has cleaner collision detection logic
  /// - Properly handles diagonal movement checking
  bool canMove(
    Direction direction, {
    double? displacement,
    Iterable<ShapeHitbox>? ignoreHitboxes,
  }) {
    // Calculate maximum distance to check based on speed and delta time
    final maxDistance = displacement ?? (speed * (lastDt * 2));

    // For diagonal directions, check both component directions
    switch (direction) {
      case Direction.upLeft:
        return canMove(
              Direction.up,
              displacement: maxDistance,
              ignoreHitboxes: ignoreHitboxes,
            ) &&
            canMove(
              Direction.left,
              displacement: maxDistance,
              ignoreHitboxes: ignoreHitboxes,
            );
      case Direction.upRight:
        return canMove(
              Direction.up,
              displacement: maxDistance,
              ignoreHitboxes: ignoreHitboxes,
            ) &&
            canMove(
              Direction.right,
              displacement: maxDistance,
              ignoreHitboxes: ignoreHitboxes,
            );
      case Direction.downLeft:
        return canMove(
              Direction.down,
              displacement: maxDistance,
              ignoreHitboxes: ignoreHitboxes,
            ) &&
            canMove(
              Direction.left,
              displacement: maxDistance,
              ignoreHitboxes: ignoreHitboxes,
            );
      case Direction.downRight:
        return canMove(
              Direction.down,
              displacement: maxDistance,
              ignoreHitboxes: ignoreHitboxes,
            ) &&
            canMove(
              Direction.right,
              displacement: maxDistance,
              ignoreHitboxes: ignoreHitboxes,
            );
      case Direction.up:
      case Direction.down:
      case Direction.left:
      case Direction.right:
        return !_hasCollisionInDirection(
          direction,
          maxDistance,
          ignoreHitboxes,
        );
    }
  }

  /// Optimized collision detection for a single direction
  /// Uses strategic raycast points for more accurate collision detection
  bool _hasCollisionInDirection(
    Direction direction,
    double maxDistance,
    Iterable<ShapeHitbox>? ignoreHitboxes,
  ) {
    final rect = rectCollision;
    final center = rect.center.toVector2();
    final size = rect.sizeVector2;
    final directionVector = direction.toVector2();

    // Calculate strategic raycast origins and extend distance
    List<Vector2> origins;
    var extendedDistance = maxDistance;

    switch (direction) {
      case Direction.left:
      case Direction.right:
        // For horizontal movement, check top, center, and bottom edges
        final halfY = size.y / 2;
        extendedDistance += size.x / 2; // Account for component width
        origins = [
          center.translated(0, -halfY * 0.8), // Near top
          center, // Center
          center.translated(0, halfY * 0.8), // Near bottom
        ];
        break;
      case Direction.up:
      case Direction.down:
        // For vertical movement, check left, center, and right edges
        final halfX = size.x / 2;
        extendedDistance += size.y / 2; // Account for component height
        origins = [
          center.translated(-halfX * 0.8, 0), // Near left
          center, // Center
          center.translated(halfX * 0.8, 0), // Near right
        ];
        break;
      default:
        // This shouldn't happen for cardinal directions
        origins = [center];
    }

    // Check if any raycast hits a collision
    return origins.any(
      (origin) =>
          raycast(
            directionVector,
            maxDistance: extendedDistance,
            origin: origin,
            ignoreHitboxes: ignoreHitboxes,
          ) !=
          null,
    );
  }
}
