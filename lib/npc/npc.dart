import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/mixins/movement.dart';
import 'package:bonfire/mixins/vision.dart';
import 'package:flame/components.dart';

export 'rotation_npc.dart';
export 'simple_npc.dart';

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
/// on 22/03/22

/// It is used to represent your NPC.
class Npc extends GameComponent with Movement, Vision {
  Npc({
    required Vector2 position,
    required Vector2 size,
    double? speed,
  }) {
    this.speed = speed ?? this.speed;
    this.position = position;
    this.size = size;
  }
}
