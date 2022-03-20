import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/mixins/attackable.dart';
import 'package:bonfire/util/mixins/movement.dart';
import 'package:flame/components.dart';

/// It is used to represent your enemies.
class Enemy extends GameComponent with Movement, Attackable {
  Enemy({
    required Vector2 position,
    required Vector2 size,
    double life = 10,
    double speed = 100,
    ReceivesAttackFromEnum receivesAttackFrom = ReceivesAttackFromEnum.PLAYER,
  }) {
    this.speed = speed;
    this.receivesAttackFrom = receivesAttackFrom;
    initialLife(life);
    this.position = position;
    this.size = size;
  }
}
