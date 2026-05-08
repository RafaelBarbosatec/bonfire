import 'package:bonfire/bonfire.dart';

class ForcesApi {
  final Movement comp;

  BonfireGameInterface get _gameRef => comp.gameRef;

  double _mass = 1.0;
  double _dragCoefficient = 0.01; // Air resistance
  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;

  // Built-in force values
  Vector2 _gravity = Vector2.zero();
  Vector2 _wind = Vector2.zero();
  Vector2 _friction = Vector2.zero();

  // Custom forces
  final Map<String, Vector2> _customForces = {};

  // Public getters
  double get mass => _mass;
  double get dragCoefficient => _dragCoefficient;
  bool get forcesEnabled => _isEnabled;
  Vector2 get gravity => _gravity;
  Vector2 get wind => _wind;
  Vector2 get friction => _friction;

  ForcesApi(this.comp);

  void setup({
    double? mass,
    double? dragCoefficient,
    bool? enabled,
    Vector2? gravity,
    Vector2? wind,
    Vector2? friction,
  }) {
    _isEnabled = enabled ?? _isEnabled;

    if (mass != null) {
      setMass(mass);
    }
    if (dragCoefficient != null) {
      setDragCoefficient(dragCoefficient);
    }

    if (gravity != null) {
      setGravity(gravity);
    }
    if (wind != null) {
      setWind(wind);
    }
    if (friction != null) {
      setFriction(friction);
    }
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
    _friction = friction;
  }

  /// Set air drag coefficient (0.0 to 1.0)
  void setDragCoefficient(double coefficient) {
    _dragCoefficient = coefficient.clamp(0.0, 1.0);
  }

  /// Set mass of the object
  void setMass(double mass) {
    assert(mass > 0, 'Mass must be positive');
    _mass = mass;
  }

  void addForce(String name, Vector2 force) {
    _customForces[name] = force;
  }

  void removeForce(String name) {
    _customForces.remove(name);
  }

  void update(double dt) {
    // Apply forces before normal movement update
    if (_isEnabled && !comp.velocity.isZero() || !_allForcesAreZero()) {
      if (comp.isVisible) {
        _applyAllForces(dt);
      }
    }
  }

  bool _allForcesAreZero() {
    return _gravity.isZero() &&
        _wind.isZero() &&
        _friction.isZero() &&
        _customForces.isEmpty &&
        _dragCoefficient == 0.0;
  }

  void _applyAllForces(double dt) {
    var currentVelocity = comp.velocity;

    // Apply forces in order of physics priority
    currentVelocity = _applyGravity(currentVelocity, dt);
    currentVelocity = _applyWind(currentVelocity, dt);
    currentVelocity = _applyCustomForces(currentVelocity, dt);
    currentVelocity = _applyFriction(currentVelocity, dt);
    currentVelocity = _applyDrag(currentVelocity, dt);

    // Update velocity
    comp.velocity = currentVelocity;
  }

  /// Apply gravity (acceleration force)
  Vector2 _applyGravity(Vector2 velocity, double dt) {
    final gravity =
        _gravity + (_gameRef.globalForces.gravity ?? Vector2.zero());
    if (gravity.isZero()) {
      return velocity;
    }

    // F = ma, so a = F/m
    final acceleration = gravity / _mass;
    return velocity + (acceleration * dt);
  }

  /// Apply wind (constant velocity addition)
  Vector2 _applyWind(Vector2 velocity, double dt) {
    final wind = _wind + (_gameRef.globalForces.wind ?? Vector2.zero());
    if (wind.isZero()) {
      return velocity;
    }

    // Wind affects lighter objects more
    final windEffect = wind / (_mass * 0.5 + 0.5);
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
    final friction =
        _friction + (_gameRef.globalForces.friction ?? Vector2.zero());
    if (friction.isZero()) {
      return velocity;
    }

    final frictionX = friction.x.clamp(0.0, 1.0);
    final frictionY = friction.y.clamp(0.0, 1.0);

    return Vector2(
      velocity.x * (1.0 - frictionX * dt),
      velocity.y * (1.0 - frictionY * dt),
    );
  }

  /// Apply air drag (velocity-dependent resistance)
  Vector2 _applyDrag(Vector2 velocity, double dt) {
    final dragCoefficient =
        _dragCoefficient + (_gameRef.globalForces.dragCoefficient ?? 0.0);
    if (dragCoefficient == 0.0) {
      return velocity;
    }

    // Drag force is proportional to velocity squared
    final speed = velocity.length;
    if (speed == 0.0) {
      return velocity;
    }

    final dragMagnitude = dragCoefficient * speed * speed;
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
  void enable() => _isEnabled = true;
  void disable() => _isEnabled = false;

  /// Quick gravity setups
  void enableEarthGravity() => setGravity(Vector2(0, 300)); // 300 pixels/s²
  void enableMoonGravity() => setGravity(Vector2(0, 50)); // Weaker gravity
  void enableZeroGravity() => setGravity(Vector2.zero());

  /// Quick friction setups
  void enableIceFriction() => setFriction(Vector2(0.01, 0.01)); // Very slippery
  void enableNormalFriction() => setFriction(
        Vector2(0.1, 0.1),
      ); // Normal surface
  void enableHighFriction() => setFriction(Vector2(0.3, 0.3)); // Rough surface

  /// Quick physics presets for common scenarios
  void makeProjectile({Vector2? gravity}) {
    setup(
      dragCoefficient: 0.005,
      gravity: gravity ?? Vector2(0, 300),
    ); // Light air resistance
  }

  void makeFlyingObject({Vector2? wind}) {
    setup(
      dragCoefficient: 0.02,
      wind: wind ?? Vector2(20, 0),
    ); // More air resistance
  }

  void makeGroundObject() {
    enableEarthGravity();
    enableNormalFriction();
    setup(dragCoefficient: 0.0); // No air resistance on ground
  }

  void makeSpaceObject() {
    enableZeroGravity();
    setup(
      dragCoefficient: 0.0,
      friction: Vector2.zero(),
    ); // No resistance in space
  }
}
