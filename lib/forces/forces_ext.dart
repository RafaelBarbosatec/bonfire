import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/forces/forces_api.dart';

/// Extension for common force patterns
extension CommonForces on ForcesApi {
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
    final direction = (target - comp.position).normalized();
    addForce(name, direction * strength);
  }

  /// Add orbital force around a center point
  void addOrbitalForce(String name, Vector2 center, double strength) {
    final toCenter = center - comp.position;
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
    final displacement = comp.position - anchor;
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
    final toTarget = comp.position - source;
    final distance = max(toTarget.length, minDistance);

    final forceDirection = toTarget.normalized();
    final force = forceDirection * (strength / (distance * distance));
    addForce(name, force);
  }
}
