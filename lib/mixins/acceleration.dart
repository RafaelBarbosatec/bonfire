import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

enum _TypeAcceleration { direction, angle, custom, function, none }

typedef AccelerationChanged = Vector2 Function(double dt, Vector2 current);

mixin Acceleration on Movement {
  _TypeAcceleration? _type;
  Vector2 customSpeed = Vector2.zero();
  Vector2 _acceleration = Vector2.zero();
  AccelerationChanged? _accelerationFunction;
  VoidCallback? _onStop;
  final Vector2 _zero = Vector2.zero();
  Direction? _direction;
  double? _moveAngle;
  bool _stopWhenSpeedZero = true;
  bool _updateAngleComponent = false;

  void applyAccelerationByDirection(
    double acceleration,
    Direction direction, {
    bool stopWhenSpeedZero = false,
    double? initialSpeed,
    VoidCallback? onStop,
  }) {
    _onStop = onStop;
    _type = _TypeAcceleration.direction;
    speed = initialSpeed ?? speed;
    if (speed == 0) {
      speed = 0.01;
    }
    _acceleration = Vector2.all(acceleration);
    _stopWhenSpeedZero = stopWhenSpeedZero;
    _direction = direction;
  }

  void applyAccelerationByAngle(
    double acceleration,
    double angle, {
    bool stopWhenSpeedZero = false,
    bool updateAngleComponent = false,
    double? initialSpeed,
    VoidCallback? onStop,
  }) {
    _updateAngleComponent = updateAngleComponent;
    _onStop = onStop;
    _type = _TypeAcceleration.angle;
    speed = initialSpeed ?? speed;
    if (speed == 0) {
      speed = 0.01;
    }
    _acceleration = Vector2.all(acceleration);
    _stopWhenSpeedZero = stopWhenSpeedZero;
    _moveAngle = angle;
    if (_updateAngleComponent) {
      this.angle = angle;
    }
  }

  void applyAcceleration(
    Vector2 acceleration,
    Vector2 initialSpeed, {
    bool stopWhenSpeedZero = false,
    VoidCallback? onStop,
  }) {
    _onStop = onStop;
    _type = _TypeAcceleration.custom;
    customSpeed = initialSpeed;
    if (customSpeed == _zero) {
      customSpeed = Vector2.all(0.01);
    }
    _acceleration = acceleration;
    _stopWhenSpeedZero = stopWhenSpeedZero;
  }

  void applyAccelerationByFunction(
    AccelerationChanged acceleration,
    Vector2 initialSpeed, {
    bool stopWhenSpeedZero = false,
    VoidCallback? onStop,
  }) {
    _onStop = onStop;
    _type = _TypeAcceleration.function;
    customSpeed = initialSpeed;
    if (customSpeed == _zero) {
      customSpeed = Vector2.all(0.01);
    }
    _accelerationFunction = acceleration;
    _stopWhenSpeedZero = stopWhenSpeedZero;
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
      case _TypeAcceleration.function:
        _applyFunction(dt);
        break;
      default:
        break;
    }
  }

  void _applyDirection() {
    if (speed == 0 && _stopWhenSpeedZero) {
      stopAcceleration();
    } else {
      if (moveFromDirection(_direction!)) {
        _updateSpeed();
      } else {
        stopAcceleration();
      }
    }
  }

  void _applyAngle() {
    if (speed == 0 && _stopWhenSpeedZero) {
      stopAcceleration();
    } else {
      if (moveFromAngle(speed, _moveAngle!)) {
        _updateSpeed();
      } else {
        stopAcceleration();
      }
    }
  }

  void _applyCustom() {
    if (customSpeed == _zero && _stopWhenSpeedZero) {
      stopAcceleration();
    } else {
      if (moveByVector(customSpeed)) {
        _updateCustomSpeed();
      } else {
        stopAcceleration();
      }
    }
  }

  void _applyFunction(double dt) {
    if (customSpeed == _zero && _stopWhenSpeedZero) {
      stopAcceleration();
    } else {
      if (moveByVector(customSpeed)) {
        _updateComplexSpeed(dt);
      } else {
        stopAcceleration();
      }
    }
  }

  void stopAcceleration() {
    _onStop?.call();
    _direction = null;
    _moveAngle = null;
    _accelerationFunction = null;
    _type = _TypeAcceleration.none;
    _onStop = null;
    idle();
  }

  void _updateSpeed() {
    if ((speed - _acceleration.x).abs() < _acceleration.x.abs() &&
        _stopWhenSpeedZero) {
      speed = 0;
    } else {
      speed += _acceleration.x;
    }
  }

  void _updateCustomSpeed() {
    if (_stopWhenSpeedZero) {
      _updateCustomSpeedToZero(_acceleration);
    } else {
      customSpeed += _acceleration;
    }
  }

  void _updateComplexSpeed(double dt) {
    _acceleration =
        _accelerationFunction?.call(dt, _acceleration) ?? Vector2.zero();
    if (_stopWhenSpeedZero) {
      _updateCustomSpeedToZero(_acceleration);
    } else {
      customSpeed += _acceleration;
    }
  }

  void _updateCustomSpeedToZero(Vector2 acceletarion) {
    if (customSpeed.x.abs() < acceletarion.x.abs()) {
      customSpeed.x = 0;
    }
    if (customSpeed.y.abs() < acceletarion.y.abs()) {
      customSpeed.y = 0;
    }
    if (customSpeed.x != 0) {
      customSpeed.x += acceletarion.x;
    }
    if (customSpeed.y != 0) {
      customSpeed.y += acceletarion.y;
    }
  }
}
