import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart';

void main() {
  group('JumperApi', () {
    test('jump() moves the component up and marks as jumping', () {
      final c = JumpingComponent()..speed = 100;
      c.jumper.jump();
      expect(c.jumper.isJumping, isTrue);
      expect(c.jumper.currentJumps, 1);
      expect(c.velocity.y, closeTo(-150, 1e-6), reason: 'default jump speed');
    });

    test('jump() respects a custom speed', () {
      final c = JumpingComponent()..speed = 100;
      c.jumper.jump(jumpSpeed: 300);
      expect(c.velocity.y, closeTo(-300, 1e-6));
    });

    test('jump() does not exceed maxJump without force', () {
      final c = JumpingComponent()..speed = 100;
      c.jumper.setMaxJump(2);
      c.jumper.jump();
      c.jumper.jump();
      expect(c.jumper.currentJumps, 2);
      expect(c.jumper.isJumping, isTrue);

      // Third jump is blocked because maxJump (2) was reached.
      final velocityBefore = c.velocity.clone();
      c.jumper.jump();
      expect(c.jumper.currentJumps, 2);
      expect(c.velocity, velocityBefore);
    });

    test('jump(force: true) bypasses maxJump', () {
      final c = JumpingComponent()..speed = 100;
      c.jumper.setMaxJump(1);
      c.jumper.jump();
      c.jumper.jump(force: true);
      expect(c.jumper.currentJumps, 2);
    });

    test('landing on the ground resets the jump state', () {
      final c = JumpingComponent()..speed = 100;
      c.jumper.jump();
      expect(c.jumper.isJumping, isTrue);

      c.jumper.handleMovementBlocked(
        c,
        CollisionData(
          normal: Vector2(0, 1),
          depth: 1,
          direction: Direction.down,
          intersectionPoints: [Vector2.zero()],
        ),
      );
      expect(c.jumper.isJumping, isFalse);
      expect(c.jumper.currentJumps, 0);
    });

    test('notifies jump state changes through the listener', () {
      final c = JumpingComponent()..speed = 100;
      final states = <JumpingStateEnum>[];
      c.jumper.onJumpStateChangedListener(states.add);

      c.jumper.jump();
      c.jumper.update(0.1);
      expect(states, contains(JumpingStateEnum.up));

      c.jumper.handleMovementBlocked(
        c,
        CollisionData(
          normal: Vector2(0, 1),
          depth: 1,
          direction: Direction.down,
          intersectionPoints: [Vector2.zero()],
        ),
      );
      // The collision system zeroes the velocity on landing; simulate that.
      c.velocity = Vector2.zero();
      c.jumper.update(0.1);
      expect(states, contains(JumpingStateEnum.idle));
    });

    test('exposes state getters', () {
      final c = JumpingComponent()..speed = 100;
      expect(c.jumper.isJumping, isFalse);
      expect(c.jumper.maxJump, 1);
      expect(c.jumper.jumpingState, JumpingStateEnum.idle);

      c.jumper.setMaxJump(3);
      expect(c.jumper.maxJump, 3);
    });

    test('dispose() clears the registered listeners', () {
      final c = JumpingComponent()..speed = 100;
      var calls = 0;
      c.jumper.onJumpStateChangedListener((_) => calls++);
      c.jumper.dispose();

      c.jumper.jump();
      c.jumper.update(0.1);
      expect(calls, 0);
    });
  });
}
