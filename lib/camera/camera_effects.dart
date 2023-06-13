import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flame/camera.dart';

class MyFollowBehavior extends FollowBehavior {
  final Vector2 movementWindow;
  MyFollowBehavior({
    required super.target,
    required this.movementWindow,
    PositionProvider? owner,
    super.maxSpeed = double.infinity,
    super.horizontalOnly = false,
    super.verticalOnly = false,
    super.priority,
  });

  @override
  void update(double dt) {
    var delta = target.position - owner.position;

    if (delta.x.abs() < movementWindow.x) {
      delta.x = 0;
    } else {
      if (delta.x > 0) {
        delta.x -= movementWindow.x;
      } else {
        delta.x += movementWindow.x;
      }
    }

    if (delta.y.abs() < movementWindow.y) {
      delta.y = 0;
    } else {
      if (delta.y > 0) {
        delta.y -= movementWindow.y;
      } else {
        delta.y += movementWindow.y;
      }
    }
    if (delta.isZero()) return;
    if (delta.length <= maxSpeed * dt) {
      owner.position = owner.position.clone()..add(delta);
    } else {
      owner.position = owner.position.clone()
        ..lerp(owner.position + delta, dt * maxSpeed);
    }
  }
}

class ShakeEffect extends Component {
  final double intensity;
  final Duration duration;
  PositionProvider get target => parent as PositionProvider;
  final void Function()? onComplete;
  double _shakeTimer = 0.0;
  ShakeEffect({
    required this.intensity,
    required this.duration,
    this.onComplete,
  }) {
    _shakeTimer = duration.inMilliseconds / 1000;
  }

  @override
  void update(double dt) {
    final shake = _shakeDelta();
    target.position = target.position.clone()..add(shake);
    if (shaking) {
      _shakeTimer -= dt;
      if (_shakeTimer < 0.0) {
        _shakeTimer = 0.0;
        onComplete?.call();
        removeFromParent();
      }
    }
    super.update(dt);
  }

  /// Whether the camera is currently shaking or not.
  bool get shaking => _shakeTimer > 0.0;

  /// Buffer to re-use for the shake delta.
  final _shakeBuffer = Vector2.zero();

  /// The random number generator to use for shaking
  final _shakeRng = Random();

  /// Generates one value between [-1, 1] * [_shakeIntensity] used once for each
  /// of the axis in the shake delta.
  double _shakeValue() => (_shakeRng.nextDouble() - 0.5) * 2 * intensity;

  /// Generates a random [Vector2] of displacement applied to the camera.
  /// This will be a random [Vector2] every tick causing a shakiness effect.
  Vector2 _shakeDelta() {
    if (shaking) {
      _shakeBuffer.setValues(_shakeValue(), _shakeValue());
    } else if (!_shakeBuffer.isZero()) {
      _shakeBuffer.setZero();
    }
    return _shakeBuffer;
  }
}
