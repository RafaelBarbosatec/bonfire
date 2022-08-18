import 'package:bonfire/bonfire.dart';

mixin Acceleration on Movement {
  Vector2 _accelerationSpeed = Vector2.zero();
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
    _accelerationSpeed = Vector2.all(initialSpeed);
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
    _accelerationSpeed = Vector2.all(initialSpeed);
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
    _accelerationSpeed = initialSpeed;
    _acceleration = acceleration;
    _stopWhenZero = stopWhenZero;
    _runCustom = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_direction != null) {
      if (_accelerationSpeed == _zero && _stopWhenZero) {
        stopAcceleration();
      } else {
        moveFromDirection(_direction!);
        _updateSpeed();
      }
    } else if (_moveAngle != null) {
      if (_accelerationSpeed == _zero && _stopWhenZero) {
        stopAcceleration();
      } else {
        moveFromAngle(speed, _moveAngle!);
        _updateSpeed();
      }
    } else if (_runCustom) {
      if (_accelerationSpeed == _zero && _stopWhenZero) {
        stopAcceleration();
      } else {
        moveByVector(_accelerationSpeed);
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
    if ((_accelerationSpeed.x - _acceleration.x).abs() <
            _acceleration.x.abs() &&
        _stopWhenZero) {
      _accelerationSpeed = _zero;
      speed = 0;
    } else {
      _accelerationSpeed += _acceleration;
      speed = _accelerationSpeed.x;
    }
  }

  void _updateCustomSpeed() {
    if (_stopWhenZero) {
      if (_accelerationSpeed.x.abs() < _acceleration.x.abs()) {
        _accelerationSpeed.x = 0;
      }
      if (_accelerationSpeed.y.abs() < _acceleration.y.abs()) {
        _accelerationSpeed.y = 0;
      }
      if (_accelerationSpeed.x != 0) {
        _accelerationSpeed.x += _acceleration.x;
      }
      if (_accelerationSpeed.y != 0) {
        _accelerationSpeed.y += _acceleration.y;
      }
    } else {
      _accelerationSpeed += _acceleration;
    }
  }
}
