import 'package:bonfire/bonfire.dart';

mixin Acceleration on Movement {
  Vector2 customSpeed = Vector2.zero();
  Vector2 _acceleration = Vector2.zero();
  final Vector2 _zero = Vector2.zero();
  Direction? _direction;
  double? _moveAngle;
  bool _runCustom = false;
  bool _stopWhenZero = true;
  bool _updateAngleComponent = false;

  void applyAccelerationDirection(
    double initialSpeed,
    double acceleration,
    Direction direction, {
    bool stopWhenZero = true,
  }) {
    customSpeed = Vector2.all(initialSpeed);
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
    customSpeed = Vector2.all(initialSpeed);
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
    customSpeed = initialSpeed;
    _acceleration = acceleration;
    _stopWhenZero = stopWhenZero;
    _runCustom = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_direction != null) {
      if (customSpeed == _zero && _stopWhenZero) {
        stopAcceleration();
      } else {
        moveFromDirection(_direction!);
        _updateSpeed();
      }
    } else if (_moveAngle != null) {
      if (customSpeed == _zero && _stopWhenZero) {
        stopAcceleration();
      } else {
        moveFromAngle(speed, _moveAngle!);
        _updateSpeed();
      }
    } else if (_runCustom) {
      if (customSpeed == _zero && _stopWhenZero) {
        stopAcceleration();
      } else {
        moveByVector(customSpeed);
        _updateCustomSpeed();
      }
    }
  }

  void stopAcceleration() {
    _runCustom = false;
    _direction = null;
    _moveAngle = null;
  }

  void _updateSpeed() {
    if ((customSpeed.x - _acceleration.x).abs() <
            _acceleration.x.abs() &&
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
