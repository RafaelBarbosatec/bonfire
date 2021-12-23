import 'package:bonfire/bonfire.dart';

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
    this.position = position;
    this.size = size;
    setupCollision(
      CollisionConfig(collisions: collisions),
    );
  }
}
