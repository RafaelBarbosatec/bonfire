import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/mixins/movement.dart';
import 'package:flame/components.dart';

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
class Npc extends GameComponent with Movement {
  Npc({
    required Vector2 position,
    required Vector2 size,
    double speed = 100,
  }) {
    this.speed = speed;
    this.position = position;
    this.size = size;
  }
}
