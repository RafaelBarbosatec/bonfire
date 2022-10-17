import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/spine_animation.dart';
import 'package:spine_core/spine_core.dart' as core;
import 'dart:ui' as ui;

import '../spine/skeleton_animation.dart';

class SpinePlayer extends Player
    with SpineAnimation, Lighting, ObjectCollision {
  SpinePlayer({
    required Vector2 position,
    required Vector2 size,
    required SkeletonAnimation skeleton,
    Direction initDirection = Direction.right,
    double speed = 150,
  }) : super(
          position: position,
          size: size,
          speed: speed,
        ) {
    // this.speed = 150* (size.x/100);
    this.skeleton = skeleton;
    lastDirection = initDirection;
    if (initDirection == Direction.left || initDirection == Direction.right) {
      lastDirectionHorizontal = initDirection;
    }
    // setupLighting(
    //   // LightingConfig(
    //   //     radius: width * 1.5,
    //   //     blurBorder: width * 1.5,
    //   //     color: Colors.red
    //   // ),
    // );
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(
              32,
              32,
            ),
            align: Vector2(
              size.x * 0.3,
              0,
            ),
          )
        ],
      ),
    );
  }
}
