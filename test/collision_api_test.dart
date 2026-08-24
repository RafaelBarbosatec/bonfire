import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart';

void main() {
  group('CollisionApi', () {
    test(
      'static body zeroes its velocity when blocked (regression: '
      'was returning absoluteCenter as reflection)',
      () {
        final a = CollidableComponent()..collision.bodyType = BodyType.static;
        final b = CollidableComponent();
        a.velocity = Vector2(0, 100);

        a.collision.setCollisionResolution(
          b,
          _collisionData(),
        );
        a.collision.onCollision({Vector2.zero()}, b);

        expect(a.velocity, Vector2.zero());
      },
    );

    test('dynamic body reflects velocity and corrects position', () {
      final a = CollidableComponent()
        ..velocity = Vector2(0, 100)
        ..position = Vector2(10, 10);
      final b = CollidableComponent()..collision.bodyType = BodyType.static;

      a.collision.setCollisionResolution(b, _collisionData());
      a.collision.onCollision({Vector2.zero()}, b);

      // normal (0,-1), depth 5 -> correction = -normal * (5 + 0.08)
      expect(a.position.y, closeTo(10 + 5.08, 1e-6));
      expect(a.position.x, closeTo(10, 1e-6));
      // reflection = normal * dot(velocity, normal) = (0, 100)
      expect(a.velocity, Vector2.zero());
    });

    test('blocked movement can be allowed by a listener', () {
      final a = CollidableComponent()..velocity = Vector2(0, 100);
      final b = CollidableComponent();

      a.collision.onBlockMovementListener((points, other) => false);
      a.collision.setCollisionResolution(b, _collisionData());
      a.collision.onCollision({Vector2.zero()}, b);

      expect(a.velocity, Vector2(0, 100), reason: 'movement was not blocked');
    });

    test('onMovementBlockedListener is notified on blocked collision', () {
      final a = CollidableComponent()..velocity = Vector2(0, 100);
      final b = CollidableComponent()..collision.bodyType = BodyType.static;
      CollisionData? notified;

      a.collision.onMovementBlockedListener((other, data) => notified = data);
      a.collision.setCollisionResolution(b, _collisionData());
      a.collision.onCollision({Vector2.zero()}, b);

      expect(notified, isNotNull);
      expect(notified!.normal, Vector2(0, -1));
      expect(notified!.direction, Direction.down);
      expect(a.collision.lastCollisionData, same(notified));
    });

    test('reflectionResolution callback overrides the default reflection', () {
      final a = CollidableComponent()..velocity = Vector2(0, 100);
      final b = CollidableComponent()..collision.bodyType = BodyType.static;

      a.collision.reflectionResolution(
        (other, data) => Vector2(0, 50), // custom reflection
      );
      a.collision.setCollisionResolution(b, _collisionData());
      a.collision.onCollision({Vector2.zero()}, b);

      expect(a.velocity, Vector2(0, 50));
    });

    test('disable() makes onCollision a no-op', () {
      final a = CollidableComponent()..velocity = Vector2(0, 100);
      final b = CollidableComponent();

      a.collision.disable();
      expect(a.collision.isEnabled, isFalse);
      a.collision.setCollisionResolution(b, _collisionData());
      a.collision.onCollision({Vector2.zero()}, b);

      expect(a.velocity, Vector2(0, 100), reason: 'collision was disabled');
    });

    test('enable() restores collision handling', () {
      final a = CollidableComponent()..velocity = Vector2(0, 100);
      final b = CollidableComponent()..collision.bodyType = BodyType.static;

      a.collision.disable();
      a.collision.enable();
      expect(a.collision.isEnabled, isTrue);

      a.collision.setCollisionResolution(b, _collisionData());
      a.collision.onCollision({Vector2.zero()}, b);
      expect(a.velocity, Vector2.zero());
    });

    test('both dynamic bodies split the position correction', () {
      final a = CollidableComponent()
        ..velocity = Vector2(0, 100)
        ..position = Vector2(10, 10);
      final b = CollidableComponent(); // dynamic by default

      a.collision.setCollisionResolution(b, _collisionData());
      a.collision.onCollision({Vector2.zero()}, b);

      // depth 5 -> +0.08 -> /2 because both are dynamic
      expect(a.position.y, closeTo(10 + (5.08 / 2), 1e-6));
    });

    test('dispose() clears callbacks', () {
      final a = CollidableComponent()..velocity = Vector2(0, 100);
      final b = CollidableComponent()..collision.bodyType = BodyType.static;
      var calls = 0;

      a.collision.onMovementBlockedListener((other, data) => calls++);
      a.collision.dispose();
      a.collision.setCollisionResolution(b, _collisionData());
      a.collision.onCollision({Vector2.zero()}, b);

      expect(calls, 0);
    });
  });
}

CollisionData _collisionData() {
  return CollisionData(
    normal: Vector2(0, -1),
    depth: 5,
    direction: Direction.down,
    intersectionPoints: [Vector2.zero()],
  );
}
