import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:flame/extensions.dart';

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
/// on 10/12/21

class CollisionGameComponent extends GameComponent with ObjectCollision {
  final String name;
  final Map<String, dynamic>? properties;

  CollisionGameComponent({
    this.name = '',
    this.properties,
    required Vector2 position,
    required Vector2 size,
    List<CollisionArea> collisions = const [],
  }) {
    this.position = this.position.copyWith(
          position: position,
          size: size,
        );
    setupCollision(
      CollisionConfig(collisions: collisions),
    );
  }
}
