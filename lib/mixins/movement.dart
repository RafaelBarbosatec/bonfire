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
mixin Movement on GameComponent {
  static const double diagonalFactor = 0.7071; // 1/sqrt(2)
  static const double defaultSpeed = 80.0;

  double speed = defaultSpeed;
  Vector2 _velocity = Vector2.zero();
  Direction direction = Direction.right;
  Direction hDirection = Direction.right;
  Direction vDirection = Direction.down;

  // Essential getters
  Vector2 get velocity => _velocity;
  bool get isMoving => !_velocity.isZero();
  bool get isIdle => _velocity.isZero();

  bool _alreadyCallIdle = false;

  // Velocity control
  set velocity(Vector2 newVelocity) {
    _velocity = newVelocity;
    if (!_velocity.isZero()) {
      direction = _getDirectionFromVelocity(_velocity);
    }
  }

  // Advanced: move by angle (for custom directions, pathfinding, etc.)
  void moveByAngle(double angleRadians, {double? speed}) {
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
      _alreadyCallIdle = false;
    } else {
      if (!_alreadyCallIdle) {
        _handleIdle();
        _alreadyCallIdle = true;
      }
    }
  }

  // Simple direction calculation from velocity
  Direction _getDirectionFromVelocity(Vector2 vel) {
    if (vel.x.abs() > vel.y.abs()) {
      hDirection = vel.x > 0 ? Direction.right : Direction.left;
      return hDirection;
    } else {
      vDirection = vel.y > 0 ? Direction.down : Direction.up;
      return vDirection;
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

  void _handleIdle() {
    if (!_alreadyCallIdle) {
      idle();
      _alreadyCallIdle = true;
    }
  }

  void idle() {}

  // Stop movement
  void stop() {
    velocity = Vector2.zero();
    _handleIdle();
  }
}

/// Extension methods for even simpler usage
extension MovementHelpers on Movement {
  // Basic cardinal movements - covers 90% of use cases
  void moveUp({double? speed, bool resetCrossAxis = false}) {
    final moveSpeed = speed ?? this.speed;
    velocity = velocity.copyWith(
      y: -moveSpeed,
      x: resetCrossAxis ? 0 : null,
    );
  }

  void moveDown({double? speed, bool resetCrossAxis = false}) {
    final moveSpeed = speed ?? this.speed;
    velocity = velocity.copyWith(
      y: moveSpeed,
      x: resetCrossAxis ? 0 : null,
    );
  }

  void moveLeft({double? speed, bool resetCrossAxis = false}) {
    final moveSpeed = speed ?? this.speed;
    velocity = velocity.copyWith(
      x: -moveSpeed,
      y: resetCrossAxis ? 0 : null,
    );
  }

  void moveRight({double? speed, bool resetCrossAxis = false}) {
    final moveSpeed = speed ?? this.speed;
    velocity = velocity.copyWith(
      x: moveSpeed,
      y: resetCrossAxis ? 0 : null,
    );
  }

  // Diagonal movements (for those who need them)
  void moveUpRight({double? speed}) {
    final moveSpeed =
        (speed ?? this.speed) * Movement.diagonalFactor; // Normalize diagonal
    velocity = Vector2(moveSpeed, -moveSpeed);
  }

  void moveUpLeft({double? speed}) {
    final moveSpeed = (speed ?? this.speed) * Movement.diagonalFactor;
    velocity = Vector2(-moveSpeed, -moveSpeed);
  }

  void moveDownRight({double? speed}) {
    final moveSpeed = (speed ?? this.speed) * Movement.diagonalFactor;
    velocity = Vector2(moveSpeed, moveSpeed);
  }

  void moveDownLeft({double? speed}) {
    final moveSpeed = (speed ?? this.speed) * Movement.diagonalFactor;
    velocity = Vector2(-moveSpeed, moveSpeed);
  }

  // Move from Direction enum
  void moveFromDirection(
    Direction direction, {
    double? speed,
    bool useDiagonal = true,
    bool resetCrossAxis = false,
  }) {
    switch (direction) {
      case Direction.up:
        moveUp(speed: speed, resetCrossAxis: resetCrossAxis);
        break;
      case Direction.down:
        moveDown(speed: speed, resetCrossAxis: resetCrossAxis);
        break;
      case Direction.left:
        moveLeft(speed: speed, resetCrossAxis: resetCrossAxis);
        break;
      case Direction.right:
        moveRight(speed: speed, resetCrossAxis: resetCrossAxis);
        break;
      case Direction.upLeft:
        if (useDiagonal) {
          moveUpLeft(speed: speed);
        } else {
          moveUp(speed: speed, resetCrossAxis: resetCrossAxis);
        }
        break;
      case Direction.upRight:
        if (useDiagonal) {
          moveUpRight(speed: speed);
        } else {
          moveUp(speed: speed, resetCrossAxis: resetCrossAxis);
        }
        break;
      case Direction.downLeft:
        if (useDiagonal) {
          moveDownLeft(speed: speed);
        } else {
          moveDown(speed: speed, resetCrossAxis: resetCrossAxis);
        }
        break;
      case Direction.downRight:
        if (useDiagonal) {
          moveDownRight(speed: speed);
        } else {
          moveDown(speed: speed, resetCrossAxis: resetCrossAxis);
        }
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

  /// Move component towards a target position with smart pathfinding
  ///
  /// This is an improved version of moveToPosition that:
  /// - Uses more precise distance calculations
  /// - Has better diagonal movement logic
  /// - Cleaner code structure and better performance
  /// - Returns true if movement occurred, false if already at target
  bool moveToPosition(
    Vector2 targetPosition, {
    double? speed,
    bool useCenter = true,
  }) {
    final moveSpeed = speed ?? this.speed;
    final diagonalSpeed = moveSpeed * Movement.diagonalFactor;
    final rect = rectCollision;

    // Get current position (center or top-left based on useCenter)
    final currentPos = useCenter ? rect.centerVector2 : rect.positionVector2;

    // Calculate the difference vector
    final diff = targetPosition - currentPos;

    // Calculate movement thresholds based on speed and delta time
    final dtSpeed = moveSpeed * lastDt * 1.1; // Add small buffer
    final dtDiagonalSpeed = diagonalSpeed * lastDt * 1.1;

    // Check if we're close enough to the target (arrived)
    if (diff.length < dtSpeed) {
      stop(); // Stop moving when we arrive
      return false;
    }

    final absDiffX = diff.x.abs();
    final absDiffY = diff.y.abs();

    // Determine movement type and execute
    if (absDiffX > dtDiagonalSpeed && absDiffY > dtDiagonalSpeed) {
      // Diagonal movement - both components are significant
      _executeDiagonalMove(diff, moveSpeed);
    } else if (absDiffX > dtSpeed) {
      // Horizontal movement only
      if (diff.x > 0) {
        moveRight(speed: moveSpeed);
      } else {
        moveLeft(speed: moveSpeed);
      }
    } else if (absDiffY > dtSpeed) {
      // Vertical movement only
      if (diff.y > 0) {
        moveDown(speed: moveSpeed);
      } else {
        moveUp(speed: moveSpeed);
      }
    } else {
      // Very close - make a direct translation to avoid oscillation
      final directMovement = diff.normalized() * dtSpeed;
      position += directMovement;
    }

    return true;
  }

  /// Execute diagonal movement with proper speed normalization
  void _executeDiagonalMove(Vector2 diff, double speed) {
    if (diff.x > 0 && diff.y > 0) {
      moveDownRight(speed: speed);
    } else if (diff.x < 0 && diff.y > 0) {
      moveDownLeft(speed: speed);
    } else if (diff.x > 0 && diff.y < 0) {
      moveUpRight(speed: speed);
    } else if (diff.x < 0 && diff.y < 0) {
      moveUpLeft(speed: speed);
    }
  }
}
