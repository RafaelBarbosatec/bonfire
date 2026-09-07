import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/mixins/attack/attack_api.dart';
import 'package:flame/components.dart';

export 'attack_api.dart';

/// Mixin that adds attack helpers to a [GameComponent].
///
/// Access all attack functionality through the [attack] API object:
/// ```dart
/// component.attack.melee(damage: 10, size: Vector2(20, 20));
/// component.attack.rangeByAngle(...);
/// ```
mixin WithAttack on Component {
  late final AttackApi attack = AttackApi(this as GameComponent);
}
