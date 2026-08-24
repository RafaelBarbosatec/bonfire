import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart';

ForcedComponent _component() {
  final c = ForcedComponent();
  c.gameRef = FakeBonfireGame();
  return c;
}

void main() {
  group('ForcesApi', () {
    test('gravity accelerates the component (F = m*a)', () {
      final c = _component();
      c.forces.setGravity(Vector2(0, 300));
      c.forces.update(1.0);
      expect(c.velocity.y, closeTo(300, 1e-6));
    });

    test('mass reduces acceleration', () {
      final c = _component();
      c.forces.setMass(2);
      c.forces.setGravity(Vector2(0, 300));
      c.forces.update(1.0);
      expect(c.velocity.y, closeTo(150, 1e-6));
    });

    test('wind pushes the component', () {
      final c = _component();
      c.forces.setWind(Vector2(50, 0));
      c.forces.update(1.0);
      expect(c.velocity.x, closeTo(50, 1e-6));
    });

    test('friction reduces velocity over time', () {
      final c = _component();
      c.velocity = Vector2(100, 0);
      c.forces.setFriction(Vector2(0.1, 0.1));
      c.forces.update(1.0);
      expect(c.velocity.x, closeTo(90, 1e-6));
    });

    test('drag is proportional to velocity squared', () {
      final c = _component();
      c.velocity = Vector2(10, 0);
      c.forces.setDragCoefficient(0.001);
      c.forces.update(1.0);
      // dragMagnitude = 0.001 * 10^2 = 0.1 -> velocity 10 - 0.1 = 9.9
      expect(c.velocity.x, closeTo(9.9, 1e-6));
    });

    test('drag never reverses the movement direction', () {
      final c = _component();
      c.velocity = Vector2(1, 0);
      c.forces.setDragCoefficient(0.5);
      c.forces.update(10.0);
      expect(c.velocity.x, closeTo(0, 1e-6), reason: 'drag must not reverse');
    });

    test('global forces from the game are combined with local ones', () {
      final c = ForcedComponent();
      c.gameRef = FakeBonfireGame(
        globalForces: GlobalForcesSettings(gravity: Vector2(0, 100)),
      );
      c.forces.setGravity(Vector2(0, 200));
      c.forces.update(1.0);
      expect(c.velocity.y, closeTo(300, 1e-6));
    });

    test('custom named forces are applied as acceleration', () {
      final c = _component();
      c.forces.addForce('boost', Vector2(0, 10));
      c.forces.update(1.0);
      expect(c.velocity.y, closeTo(10, 1e-6));
      c.forces.removeForce('boost');
      c.forces.update(1.0);
      expect(c.velocity.y, closeTo(10, 1e-6), reason: 'force removed');
    });

    test('disable() stops applying forces', () {
      final c = _component();
      c.forces.setGravity(Vector2(0, 300));
      c.forces.disable();
      expect(c.forces.isEnabled, isFalse);
      c.forces.update(1.0);
      expect(c.velocity, Vector2.zero());
    });

    test('enable() restores force application', () {
      final c = _component();
      c.forces.setGravity(Vector2(0, 300));
      c.forces.disable();
      c.forces.enable();
      c.forces.update(1.0);
      expect(c.velocity.y, closeTo(300, 1e-6));
    });

    test('setup() applies multiple settings at once', () {
      final c = _component();
      c.forces.setup(
        mass: 2,
        gravity: Vector2(0, 300),
        dragCoefficient: 0.1,
      );
      expect(c.forces.mass, 2);
      expect(c.forces.gravity, Vector2(0, 300));
      expect(c.forces.dragCoefficient, closeTo(0.1, 1e-6));
    });

    test('presets configure common scenarios', () {
      final c = _component();
      c.forces.makeProjectile();
      expect(c.forces.gravity, Vector2(0, 300));
      expect(c.forces.dragCoefficient, closeTo(0.005, 1e-6));

      c.forces.makeSpaceObject();
      expect(c.forces.gravity, Vector2.zero());
      expect(c.forces.dragCoefficient, 0.0);
      expect(c.forces.friction, Vector2.zero());
    });

    test('drag coefficient is clamped to [0, 1]', () {
      final c = _component();
      c.forces.setDragCoefficient(5.0);
      expect(c.forces.dragCoefficient, 1.0);
      c.forces.setDragCoefficient(-1.0);
      expect(c.forces.dragCoefficient, 0.0);
    });
  });
}
