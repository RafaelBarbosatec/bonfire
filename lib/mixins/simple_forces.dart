import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Simple physics forces for SimpleMovement
///
/// This mixin adds realistic physics forces like gravity, friction, wind, etc.
/// It's much simpler than the original HandleForces but covers most common cases.
mixin SimpleForces on SimpleMovement {
  double _mass = 1.0;
  double _dragCoefficient = 0.01; // Air resistance
  bool _forcesEnabled = true;

  // Built-in force values
  Vector2 _gravity = Vector2.zero();
  Vector2 _wind = Vector2.zero();
  Vector2 _friction = Vector2.zero();

  // Custom forces
  final Map<String, Vector2> _customForces = {};

  // Public getters
  double get mass => _mass;
  double get dragCoefficient => _dragCoefficient;
  bool get forcesEnabled => _forcesEnabled;
  Vector2 get gravity => _gravity;
  Vector2 get wind => _wind;
  Vector2 get friction => _friction;

  /// Setup basic physics properties
  void setupPhysics({
    double? mass,
    double? dragCoefficient,
    bool? enabled,
  }) {
    if (mass != null) {
      assert(mass > 0, 'Mass must be positive');
      _mass = mass;
    }
    _dragCoefficient = (dragCoefficient ?? _dragCoefficient).clamp(0.0, 1.0);
    _forcesEnabled = enabled ?? _forcesEnabled;
  }

  /// Set gravity force (pixels/second²)
  void setGravity(Vector2 gravity) {
    _gravity = gravity;
  }

  /// Set wind force (constant velocity addition)
  void setWind(Vector2 wind) {
    _wind = wind;
  }

  /// Set friction force (velocity reduction factor)
  void setFriction(Vector2 friction) {
    _friction = Vector2(
      friction.x.clamp(0.0, 1.0),
      friction.y.clamp(0.0, 1.0),
    );
  }

  /// Add a custom force by name
  void addForce(String name, Vector2 force) {
    _customForces[name] = force;
  }

  /// Remove a custom force
  void removeForce(String name) {
    _customForces.remove(name);
  }

  /// Clear all custom forces
  void clearForces() {
    _customForces.clear();
  }

  @override
  void update(double dt) {
    // Apply forces before normal movement update
    if (_forcesEnabled && !velocity.isZero() || !_allForcesAreZero()) {
      _applyAllForces(dt);
    }
    super.update(dt);
  }

  bool _allForcesAreZero() {
    return _gravity.isZero() &&
        _wind.isZero() &&
        _friction.isZero() &&
        _customForces.isEmpty &&
        _dragCoefficient == 0.0;
  }

  void _applyAllForces(double dt) {
    var currentVelocity = velocity;

    // Apply forces in order of physics priority
    currentVelocity = _applyGravity(currentVelocity, dt);
    currentVelocity = _applyWind(currentVelocity, dt);
    currentVelocity = _applyCustomForces(currentVelocity, dt);
    currentVelocity = _applyFriction(currentVelocity, dt);
    currentVelocity = _applyDrag(currentVelocity, dt);

    // Update velocity
    velocity = currentVelocity;
  }

  /// Apply gravity (acceleration force)
  Vector2 _applyGravity(Vector2 velocity, double dt) {
    if (_gravity.isZero()) {
      return velocity;
    }

    // F = ma, so a = F/m
    final acceleration = _gravity / _mass;
    return velocity + (acceleration * dt);
  }

  /// Apply wind (constant velocity addition)
  Vector2 _applyWind(Vector2 velocity, double dt) {
    if (_wind.isZero()) {
      return velocity;
    }

    // Wind affects lighter objects more
    final windEffect = _wind / (_mass * 0.5 + 0.5);
    return velocity + (windEffect * dt);
  }

  /// Apply custom forces (treated as acceleration)
  Vector2 _applyCustomForces(Vector2 velocity, double dt) {
    if (_customForces.isEmpty) {
      return velocity;
    }

    var result = velocity;
    for (final force in _customForces.values) {
      final acceleration = force / _mass;
      result += acceleration * dt;
    }
    return result;
  }

  /// Apply friction (velocity reduction)
  Vector2 _applyFriction(Vector2 velocity, double dt) {
    if (_friction.isZero()) {
      return velocity;
    }

    final frictionX = _friction.x.clamp(0.0, 1.0);
    final frictionY = _friction.y.clamp(0.0, 1.0);

    return Vector2(
      velocity.x * (1.0 - frictionX * dt),
      velocity.y * (1.0 - frictionY * dt),
    );
  }

  /// Apply air drag (velocity-dependent resistance)
  Vector2 _applyDrag(Vector2 velocity, double dt) {
    if (_dragCoefficient == 0.0) {
      return velocity;
    }

    // Drag force is proportional to velocity squared
    final speed = velocity.length;
    if (speed == 0.0) {
      return velocity;
    }

    final dragMagnitude = _dragCoefficient * speed * speed;
    final dragDirection = velocity.normalized() * -1;
    final dragForce = dragDirection * dragMagnitude;

    // Apply drag as deceleration
    final deceleration = dragForce / _mass;
    final newVelocity = velocity + (deceleration * dt);

    // Prevent drag from reversing direction
    if (newVelocity.dot(velocity) < 0) {
      return Vector2.zero();
    }

    return newVelocity;
  }

  /// Enable/disable forces temporarily
  void enableForces() => _forcesEnabled = true;
  void disableForces() => _forcesEnabled = false;

  /// Quick gravity setups
  void enableEarthGravity() => setGravity(Vector2(0, 300)); // 300 pixels/s²
  void enableMoonGravity() => setGravity(Vector2(0, 50)); // Weaker gravity
  void enableZeroGravity() => setGravity(Vector2.zero());

  /// Quick friction setups
  void enableIceFriction() => setFriction(Vector2(0.01, 0.01)); // Very slippery
  void enableNormalFriction() =>
      setFriction(Vector2(0.1, 0.1)); // Normal surface
  void enableHighFriction() => setFriction(Vector2(0.3, 0.3)); // Rough surface

  /// Quick physics presets for common scenarios
  void makeProjectile({Vector2? gravity}) {
    setGravity(gravity ?? Vector2(0, 300));
    setupPhysics(dragCoefficient: 0.005); // Light air resistance
  }

  void makeFlyingObject({Vector2? wind}) {
    setWind(wind ?? Vector2(20, 0));
    setupPhysics(dragCoefficient: 0.02); // More air resistance
  }

  void makeGroundObject() {
    enableEarthGravity();
    enableNormalFriction();
    setupPhysics(dragCoefficient: 0.0); // No air resistance on ground
  }

  void makeSpaceObject() {
    enableZeroGravity();
    setFriction(Vector2.zero());
    setupPhysics(dragCoefficient: 0.0); // No resistance in space
  }
}

/// Extension for common force patterns
extension CommonForces on SimpleForces {
  /// Add temporary impulse force (like explosion, jump, etc.)
  void addImpulse(String name, Vector2 force, {double duration = 0.1}) {
    addForce(name, force);

    // Remove force after duration (you'd need a timer system for this)
    // This is a simplified version - in practice you might want a proper timer
    Future.delayed(Duration(milliseconds: (duration * 1000).round()), () {
      removeForce(name);
    });
  }

  /// Add magnetic force towards a target
  void addMagneticForce(String name, Vector2 target, double strength) {
    final direction = (target - position).normalized();
    addForce(name, direction * strength);
  }

  /// Add orbital force around a center point
  void addOrbitalForce(String name, Vector2 center, double strength) {
    final toCenter = center - position;
    final distance = toCenter.length;

    if (distance > 0) {
      // Centripetal force
      final forceDirection = toCenter.normalized();
      final force = forceDirection * (strength / (distance * distance));
      addForce(name, force);
    }
  }

  /// Add spring force (like elastic band)
  void addSpringForce(
    String name,
    Vector2 anchor,
    double stiffness, {
    double restLength = 0,
  }) {
    final displacement = position - anchor;
    final distance = displacement.length;
    final extension = distance - restLength;

    if (distance > 0) {
      final springForce = displacement.normalized() * (-stiffness * extension);
      addForce(name, springForce);
    }
  }

  /// Add repulsion force from a point
  void addRepulsionForce(
    String name,
    Vector2 source,
    double strength, {
    double minDistance = 10,
  }) {
    final toTarget = position - source;
    final distance = max(toTarget.length, minDistance);

    final forceDirection = toTarget.normalized();
    final force = forceDirection * (strength / (distance * distance));
    addForce(name, force);
  }
}
