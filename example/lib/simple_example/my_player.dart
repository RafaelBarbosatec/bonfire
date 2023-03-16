import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/player_sprite_sheet.dart';
import 'package:flutter/material.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 19/10/21
class MyPlayer extends SimplePlayer with ObjectCollision {
  MyPlayer(Vector2 position)
      : super(
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
          size: Vector2.all(32),
          position: position,
          life: 200,
        ) {
    /// here we configure collision of the player
    // TODO
    // setupCollision(
    //   CollisionConfig(
    //     collisions: [
    //       CollisionArea.rectangle(size: Vector2.all(32)),
    //     ],
    //   ),
    // );
  }

  @override
  Future<void> onLoad() {
    debugColor = const Color(0xffffffff);
    add(RectangleHitbox(size: size));
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    print('onCollision: $this -> $other');
    super.onCollision(points, other);
  }
}
