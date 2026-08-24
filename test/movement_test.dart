import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart';

void main() {
  group('Movement', () {
    test('moveRight moves to the right and updates direction', () {
      final c = MovableComponent()..speed = 100;
      c.moveRight();
      expect(c.velocity, Vector2(100, 0));
      expect(c.direction, Direction.right);
      expect(c.hDirection, Direction.right);

      c.update(1.0);
      expect(c.position.x, closeTo(100, 1e-6));
      expect(c.position.y, closeTo(0, 1e-6));
    });

    test('moveLeft moves to the left', () {
      final c = MovableComponent()..speed = 100;
      c.moveLeft();
      expect(c.velocity, Vector2(-100, 0));
      expect(c.direction, Direction.left);

      c.update(1.0);
      expect(c.position.x, closeTo(-100, 1e-6));
    });

    test('moveUp moves up and updates vDirection', () {
      final c = MovableComponent()..speed = 100;
      c.moveUp();
      expect(c.velocity, Vector2(0, -100));
      expect(c.direction, Direction.up);
      expect(c.vDirection, Direction.up);

      c.update(1.0);
      expect(c.position.y, closeTo(-100, 1e-6));
    });

    test('moveDown moves down', () {
      final c = MovableComponent()..speed = 100;
      c.moveDown();
      expect(c.velocity, Vector2(0, 100));
      c.update(1.0);
      expect(c.position.y, closeTo(100, 1e-6));
    });

    test('speed override is respected', () {
      final c = MovableComponent();
      c.moveRight(speed: 250);
      expect(c.velocity, Vector2(250, 0));
    });

    test('resetCrossAxis zeroes the other axis', () {
      final c = MovableComponent()..speed = 100;
      c.moveRight();
      c.moveUp(resetCrossAxis: true);
      expect(c.velocity, Vector2(0, -100));
    });

    test('diagonal movement is normalized', () {
      final c = MovableComponent()..speed = 100;
      c.moveUpRight();
      final expected = 100 * Movement.diagonalFactor;
      expect(c.velocity.x, closeTo(expected, 1e-6));
      expect(c.velocity.y, closeTo(-expected, 1e-6));
      expect(c.velocity.length, closeTo(100, 1e-6));
    });

    test('moveFromDirection maps the Direction enum', () {
      final c = MovableComponent()..speed = 100;
      c.moveFromDirection(Direction.downLeft);
      final expected = 100 * Movement.diagonalFactor;
      expect(c.velocity.x, closeTo(-expected, 1e-6));
      expect(c.velocity.y, closeTo(expected, 1e-6));
    });

    test('moveFromDirection with useDiagonal=false keeps axis movement', () {
      final c = MovableComponent()..speed = 100;
      c.moveFromDirection(Direction.downLeft, useDiagonal: false);
      expect(c.velocity.x, closeTo(0, 1e-6));
      expect(c.velocity.y, closeTo(100, 1e-6));
    });

    test('moveByAngle converts radians to velocity', () {
      final c = MovableComponent()..speed = 100;
      c.moveByAngle(0);
      expect(c.velocity.x, closeTo(100, 1e-6));
      expect(c.velocity.y, closeTo(0, 1e-6));

      c.moveByAngle(pi / 2);
      expect(c.velocity.x, closeTo(0, 1e-6));
      expect(c.velocity.y, closeTo(100, 1e-6));
    });

    test('moveToward moves toward the target position', () {
      final c = MovableComponent()
        ..speed = 100
        ..position = Vector2(0, 0);
      c.moveToward(Vector2(0, -50)); // target above
      expect(c.velocity.y, closeTo(-100, 1e-6));
      expect(c.velocity.x, closeTo(0, 1e-6));
    });

    test('stop() zeroes the velocity and stops movement', () {
      final c = MovableComponent()..speed = 100;
      c.moveRight();
      c.update(1.0);
      c.stop();
      expect(c.velocity, Vector2.zero());

      final posBefore = c.position.clone();
      c.update(1.0);
      expect(c.position, posBefore);
    });

    test('isMoving requires consecutive moving frames', () {
      final c = MovableComponent()..speed = 100;
      c.moveRight();
      expect(c.isMoving, isFalse);
      c.update(0.016);
      expect(c.isMoving, isFalse);
      c.update(0.016);
      expect(c.isMoving, isFalse);
      c.update(0.016);
      expect(c.isMoving, isTrue);

      c.stop();
      c.update(0.016);
      expect(c.isMoving, isFalse);
    });

    test('isIdle reflects zero velocity', () {
      final c = MovableComponent()..speed = 100;
      expect(c.isIdle, isTrue);
      c.moveRight();
      expect(c.isIdle, isFalse);
      c.stop();
      expect(c.isIdle, isTrue);
    });

    test('onMove() is called while moving and not while idle', () {
      final c = _OnMoveSpy()..speed = 100;
      c.moveRight();
      c.update(0.016);
      expect(c.onMoveCalls, greaterThanOrEqualTo(1));

      c.stop();
      final before = c.onMoveCalls;
      c.update(0.016);
      expect(c.onMoveCalls, before, reason: 'idle frames must not call onMove');
    });

    test('velocity setter keeps last direction when zeroed', () {
      final c = MovableComponent()..speed = 100;
      c.moveRight();
      expect(c.direction, Direction.right);
      c.stop();
      expect(c.direction, Direction.right);
    });
  });
}

class _OnMoveSpy extends GameComponent with Movement {
  int onMoveCalls = 0;

  @override
  void onMove() {
    onMoveCalls++;
    super.onMove();
  }
}
