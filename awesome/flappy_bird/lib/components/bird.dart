import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flappy_bird/components/pipe/pipe_line.dart';
import 'package:flappy_bird/components/pipe/pipe_line_controller.dart';
import 'package:flappy_bird/util/spritesheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Bird extends PlatformPlayer with HandleForces, TapGesture {
  Vector2? _initialPosition;
  Bird({required super.position})
      : super(
          size: Vector2(34, 24),
          animation: PlatformAnimations(
            idleRight: Spritesheet.flapMidle,
            runRight: Spritesheet.flapMidle,
            jump: PlatformJumpAnimations(
              jumpUpRight: Spritesheet.flapDown,
              jumpDownRight: Spritesheet.flapUp,
            ),
          ),
        ) {
    _initialPosition = position.clone();
    anchor = Anchor.center;
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.id == LogicalKeyboardKey.space &&
        event.event == ActionEvent.DOWN) {
      doJump();
    }
    super.onJoystickAction(event);
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    // TODO: disable directional
  }

  @override
  void onTapDownScreen(GestureEvent event) {
    doJump();
    super.onTapDownScreen(event);
  }

  void doJump() async {
    jump(force: true, jumpSpeed: 160);
  }

  final graus90 = 1.0472;

  @override
  void update(double dt) {
    angle = lerpDouble(angle, (velocity.y > 0 ? 1 : -1) * graus90, dt) ?? 0;
    super.update(dt);
  }

  @override
  void onTap() {}

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2.all(24),
        position: Vector2(5, 0),
      ),
    );
    return super.onLoad();
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    gameRef.pauseEngine();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over'),
          actions: [
            ElevatedButton(
              onPressed: _resetGame,
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
    return super.onBlockMovement(intersectionPoints, other);
  }

  void _resetGame() {
    gameRef.query<PipeLineController>().first.reset();
    gameRef.query<PipeLine>().forEach((element) => element.removeFromParent());
    setZeroVelocity();
    position = _initialPosition!.clone();
    lastDirection = Direction.right;
    gameRef.resumeEngine();
    Navigator.pop(context);
  }
}
