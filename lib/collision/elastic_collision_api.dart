import 'dart:math';

import 'package:bonfire/bonfire.dart';

typedef OnBounceCallback = Vector2? Function(
  PositionComponent other,
  CollisionData data,
  Vector2 impulse,
);

class ElasticCollisionApi {
  final WithCollision comp;
  ElasticCollisionApi(this.comp) {
    comp.collision.reflectionResolution(_reflectionResolution);
  }
  final List<OnBounceCallback> _onBounceCallbacks = [];

  bool get enabled => _enabled;
  double get restitution => _restitution;
  double _restitution = 1.0; // Initial restitution (can be configured)
  bool _enabled = true;
  double _minBounceVelocity = 10.0; // Minimum velocity to bounce

  void setup({
    double? bounciness,
    double? minBounceVelocity,
  }) {
    _minBounceVelocity = minBounceVelocity ?? _minBounceVelocity;
    _restitution = bounciness ?? _restitution;
  }

  void enable() => _enabled = true;
  void disable() => _enabled = false;

  void onBounce(OnBounceCallback callback) {
    _onBounceCallbacks.add(callback);
  }

  void dispose() {
    _onBounceCallbacks.clear();
  }

  Vector2? _reflectionResolution(PositionComponent other, CollisionData data) {
    if (_enabled) {
      if (comp.velocity.length < _minBounceVelocity) {
        return null;
      }
      final otherVelocity =
          (other is Movement) ? other.velocity : Vector2.zero();
      final relativeVelocity = otherVelocity - comp.velocity;

      if (relativeVelocity.dot(data.normal) > 0) {
        return null;
      }

      final bRestitution = (other is WithElasticCollision)
          ? other.elasticCollision.restitution
          : _restitution;

      final double e = min(_restitution, bRestitution);

      var j = -(1 + e) * relativeVelocity.dot(data.normal);

      final mass = (this is WithForces) ? (this as WithForces).forces.mass : 1;
      final massB = (other is WithForces) ? other.forces.mass : 1;
      j /= mass + massB;

      final impulse = data.normal * j;

      _onBounce(other, data, impulse);

      // Sistema base: velocity -= getVelocityReflection
      // Para reflexão com coeficiente e: v_final = -e * v_normal + v_tangencial
      // Como sistema subtrai nosso retorno, retornamos: v_normal + impulse
      final normalComponent = data.normal * comp.velocity.dot(data.normal);
      return normalComponent + impulse;
    }
    return null;
  }

  void _onBounce(PositionComponent other, CollisionData data, Vector2 impulse) {
    for (final callback in _onBounceCallbacks) {
      callback(other, data, impulse);
    }
  }
}
