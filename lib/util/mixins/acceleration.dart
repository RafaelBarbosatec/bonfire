import 'package:bonfire/bonfire.dart';

enum _TypeAcceleration { direction, angle, custom, none }

mixin Acceleration on Movement {
  _TypeAcceleration _type = _TypeAcceleration.direction;
  Vector2 customSpeed = Vector2.zero();
  Vector2 _acceleration = Vector2.zero();
  final Vector2 _zero = Vector2.zero();
  Direction? _direction;
  double? _moveAngle;
  bool _stopWhenZero = true;
  bool _updateAngleComponent = false;

  void applyAccelerationDirection(
    double initialSpeed,
    double acceleration,
    Direction direction, {
    bool stopWhenZero = true,
  }) {
    _type = _TypeAcceleration.direction;
    customSpeed = Vector2.all(initialSpeed == 0 ? 0.1 : initialSpeed);
    _acceleration = Vector2.all(acceleration);
    _stopWhenZero = stopWhenZero;
    _direction = direction;
  }

  void applyAccelerationAngle(
    double initialSpeed,
    double acceleration,
    double angle, {
    bool stopWhenZero = true,
  }) {
    _type = _TypeAcceleration.angle;
    customSpeed = Vector2.all(initialSpeed == 0 ? 0.1 : initialSpeed);
    _acceleration = Vector2.all(acceleration);
    _stopWhenZero = stopWhenZero;
    _moveAngle = angle;
    if (_updateAngleComponent) {
      this.angle = angle;
    }
  }

  void applyAcceleration(
    Vector2 initialSpeed,
    Vector2 acceleration, {
    bool stopWhenZero = true,
  }) {
    _type = _TypeAcceleration.custom;
    customSpeed = initialSpeed == _zero ? Vector2.all(0.1) : initialSpeed;
    _acceleration = acceleration;
    _stopWhenZero = stopWhenZero;
  }

  @override
  void update(double dt) {
    super.update(dt);
    switch (_type) {
      case _TypeAcceleration.direction:
        _applyDirection();
        break;
      case _TypeAcceleration.angle:
        _applyAngle();
        break;
      case _TypeAcceleration.custom:
        _applyCustom();
        break;
      case _TypeAcceleration.none:
        break;
    }
  }

  void _applyDirection() {
    if (customSpeed == _zero && _stopWhenZero) {
      stopAcceleration();
    } else {
      moveFromDirection(_direction!);
      _updateSpeed();
    }
  }

  void _applyAngle() {
    if (customSpeed == _zero && _stopWhenZero) {
      stopAcceleration();
    } else {
      moveFromAngle(speed, _moveAngle!);
      _updateSpeed();
    }
  }

  void _applyCustom() {
    if (customSpeed == _zero && _stopWhenZero) {
      stopAcceleration();
    } else {
      moveByVector(customSpeed);
      _updateCustomSpeed();
    }
  }

  void stopAcceleration() {
    _direction = null;
    _moveAngle = null;
    _type = _TypeAcceleration.none;
  }

  void _updateSpeed() {
    if ((customSpeed.x - _acceleration.x).abs() < _acceleration.x.abs() &&
        _stopWhenZero) {
      customSpeed = _zero;
      speed = 0;
    } else {
      customSpeed += _acceleration;
      speed = customSpeed.x;
    }
  }

  void _updateCustomSpeed() {
    if (_stopWhenZero) {
      if (customSpeed.x.abs() < _acceleration.x.abs()) {
        customSpeed.x = 0;
      }
      if (customSpeed.y.abs() < _acceleration.y.abs()) {
        customSpeed.y = 0;
      }
      if (customSpeed.x != 0) {
        customSpeed.x += _acceleration.x;
      }
      if (customSpeed.y != 0) {
        customSpeed.y += _acceleration.y;
      }
    } else {
      customSpeed += _acceleration;
    }
  }
}
