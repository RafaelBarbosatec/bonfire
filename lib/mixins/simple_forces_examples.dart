import 'package:bonfire/bonfire.dart';

/// Examples of using SimpleForces with SimpleMovement

// Example 1: Projectile with gravity and air resistance
class Cannonball extends GameComponent
    with SimpleMovement, SimpleForces, HasCollisionDetection {
  Cannonball({
    required Vector2 position,
    required Vector2 initialVelocity,
  }) {
    this.position = position;
    add(CircleHitbox(radius: 8));

    // Setup projectile physics
    makeProjectile(); // Built-in preset: gravity + light air resistance
    velocity = initialVelocity;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Remove if hits ground (y > 600)
    if (position.y > 600) {
      removeFromParent();
    }
  }
}

// Example 2: Paper airplane affected by wind
class PaperAirplane extends GameComponent
    with SimpleMovement, SimpleForces, HasCollisionDetection {
  PaperAirplane({required Vector2 position}) {
    this.position = position;
    add(RectangleHitbox(size: Vector2(24, 8)));

    // Light object affected by wind and drag
    setupPhysics(mass: 0.5, dragCoefficient: 0.05);
    setGravity(Vector2(0, 50)); // Light gravity
    setWind(Vector2(30, -10)); // Wind pushes right and up

    velocity = Vector2(100, -20);
  }
}

// Example 3: Car with friction and engine force
class Car extends GameComponent
    with SimpleMovement, SimpleForces, HasCollisionDetection {
  final double _enginePower = 200.0;

  Car({required Vector2 position}) {
    this.position = position;
    add(RectangleHitbox(size: Vector2(40, 20)));

    // Heavy object with friction
    setupPhysics(mass: 2.0);
    enableNormalFriction(); // Ground friction

    // No gravity (car on flat ground)
    enableZeroGravity();
  }

  void accelerate() {
    // Add engine force in the direction the car is facing
    final forceDirection = Vector2(1, 0); // Assume facing right
    addForce('engine', forceDirection * _enginePower);
  }

  void brake() {
    // Add braking force opposite to velocity
    if (!velocity.isZero()) {
      final brakeForce = velocity.normalized() * -300;
      addForce('brakes', brakeForce);
    }
  }

  void stopAccelerating() {
    removeForce('engine');
  }

  void stopBraking() {
    removeForce('brakes');
  }
}

// Example 4: Spaceship in zero gravity with thrusters
class Spaceship extends GameComponent
    with SimpleMovement, SimpleForces, HasCollisionDetection {
  final double _thrustPower = 150.0;

  Spaceship({required Vector2 position}) {
    this.position = position;
    add(RectangleHitbox(size: Vector2(20, 30)));

    // Space physics: no gravity, no friction, no drag
    makeSpaceObject();
    setupPhysics(mass: 1.5);
  }

  void thrustUp() => addForce('thrust', Vector2(0, -_thrustPower));
  void thrustDown() => addForce('thrust', Vector2(0, _thrustPower));
  void thrustLeft() => addForce('thrust', Vector2(-_thrustPower, 0));
  void thrustRight() => addForce('thrust', Vector2(_thrustPower, 0));
  void stopThrust() => removeForce('thrust');

  @override
  void update(double dt) {
    super.update(dt);

    // Limit max velocity in space
    if (velocity.length > 200) {
      velocity = velocity.normalized() * 200;
    }
  }
}

// Example 5: Platformer character with variable gravity
class PlatformerPlayer extends GameComponent
    with SimpleMovement, SimpleForces, SimpleCollision, HasCollisionDetection {
  bool _isOnGround = false;
  bool _jumpPressed = false;
  final double _jumpPower = 400.0;

  PlatformerPlayer({required Vector2 position}) {
    this.position = position;
    add(RectangleHitbox(size: Vector2(16, 24)));

    setupCollision(bodyType: BodyType.dynamic);
    makeGroundObject(); // Gravity + friction
    setupPhysics(mass: 1.0);
  }

  void jump() {
    if (_isOnGround && !_jumpPressed) {
      _jumpPressed = true;

      // Add upward impulse
      velocity = Vector2(velocity.x, -_jumpPower);
      _isOnGround = false;
    }
  }

  void moveLeftRight(double direction) {
    // direction: -1 for left, +1 for right, 0 for stop
    if (direction != 0) {
      addForce('movement', Vector2(direction * 300, 0));
    } else {
      removeForce('movement');
    }
  }

  @override
  void onMovementBlocked(PositionComponent other, CollisionData data) {
    super.onMovementBlocked(other, data);

    // Check if landed on ground
    if (data.direction == Direction.down) {
      _isOnGround = true;
      _jumpPressed = false;
    }
  }
}

// Example 6: Magnetic object attracted to metal
class MetalBall extends GameComponent
    with SimpleMovement, SimpleForces, HasCollisionDetection {
  Vector2? _magnetPosition;

  MetalBall({required Vector2 position}) {
    this.position = position;
    add(CircleHitbox(radius: 10));

    setupPhysics(mass: 1.2);
    enableEarthGravity();
    enableIceFriction(); // Very slippery
  }

  void setMagnet(Vector2 magnetPos) {
    _magnetPosition = magnetPos;
  }

  void removeMagnet() {
    _magnetPosition = null;
    removeForce('magnetic');
  }

  @override
  void update(double dt) {
    // Update magnetic force
    if (_magnetPosition != null) {
      addMagneticForce('magnetic', _magnetPosition!, 100.0);
    }

    super.update(dt);
  }
}

// Example 7: Orbital satellite
class Satellite extends GameComponent
    with SimpleMovement, SimpleForces, HasCollisionDetection {
  final Vector2 _planetCenter;

  Satellite({
    required Vector2 position,
    required Vector2 planetCenter,
    required Vector2 initialVelocity,
  }) : _planetCenter = planetCenter {
    this.position = position;
    add(RectangleHitbox(size: Vector2(8, 8)));

    makeSpaceObject(); // No gravity, friction, or drag
    setupPhysics(mass: 0.8);
    velocity = initialVelocity;
  }

  @override
  void update(double dt) {
    // Apply orbital force towards planet
    addOrbitalForce('gravity', _planetCenter, 5000.0);

    super.update(dt);
  }
}

// Example 8: Spring-connected objects
class SpringyObject extends GameComponent
    with SimpleMovement, SimpleForces, HasCollisionDetection {
  Vector2? _anchorPoint;
  double _springStiffness = 50.0;
  double _restLength = 100.0;

  SpringyObject({required Vector2 position}) {
    this.position = position;
    add(CircleHitbox(radius: 6));

    setupPhysics(mass: 1.0, dragCoefficient: 0.02);
    enableEarthGravity();
  }

  void attachToAnchor(Vector2 anchor, {double? stiffness, double? restLength}) {
    _anchorPoint = anchor;
    _springStiffness = stiffness ?? _springStiffness;
    _restLength = restLength ?? _restLength;
  }

  void detachFromAnchor() {
    _anchorPoint = null;
    removeForce('spring');
  }

  @override
  void update(double dt) {
    // Apply spring force if attached
    if (_anchorPoint != null) {
      addSpringForce(
        'spring',
        _anchorPoint!,
        _springStiffness,
        restLength: _restLength,
      );
    }

    super.update(dt);
  }
}

// Example 9: Physics playground setup
class PhysicsPlayground extends GameComponent {
  void setupPhysicsDemo() {
    // Projectiles
    add(
      Cannonball(
        position: Vector2(50, 400),
        initialVelocity: Vector2(200, -300),
      ),
    );

    // Floating objects
    add(PaperAirplane(position: Vector2(100, 200)));

    // Ground objects
    add(Car(position: Vector2(300, 450)));

    // Space objects
    add(Spaceship(position: Vector2(600, 100)));

    // Orbital system
    add(
      Satellite(
        position: Vector2(400, 200),
        planetCenter: Vector2(400, 300),
        initialVelocity: Vector2(80, 0),
      ),
    );

    // Spring system
    final springObj = SpringyObject(position: Vector2(500, 300));
    springObj.attachToAnchor(Vector2(500, 100));
    add(springObj);

    // Magnetic system
    final metalBall = MetalBall(position: Vector2(200, 300));
    metalBall.setMagnet(Vector2(200, 100));
    add(metalBall);
  }
}

/// Usage Summary:

/// Basic gravity setup:
/// ```dart
/// class FallingObject extends GameComponent with SimpleMovement, SimpleForces {
///   FallingObject() {
///     enableEarthGravity(); // Quick setup
///     // Or custom: setGravity(Vector2(0, 300));
///   }
/// }
/// ```

/// Multiple forces:
/// ```dart
/// setupPhysics(mass: 2.0, dragCoefficient: 0.01);
/// setGravity(Vector2(0, 300));    // Downward gravity
/// setWind(Vector2(20, 0));        // Rightward wind
/// setFriction(Vector2(0.1, 0.1)); // Surface friction
/// addForce('engine', Vector2(100, 0)); // Custom force
/// ```

/// Presets for common scenarios:
/// - `makeProjectile()` - For bullets, cannonballs, etc.
/// - `makeFlyingObject()` - For airplanes, birds, etc.  
/// - `makeGroundObject()` - For cars, characters on ground
/// - `makeSpaceObject()` - For spaceships, satellites

/// Advanced force patterns:
/// - `addMagneticForce()` - Attraction to a point
/// - `addOrbitalForce()` - Circular orbital motion
/// - `addSpringForce()` - Elastic connection
/// - `addRepulsionForce()` - Push away from point