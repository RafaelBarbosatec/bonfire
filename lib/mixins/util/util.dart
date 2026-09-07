import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/mixins/util/util_api.dart';
import 'package:flame/components.dart';

export 'util_api.dart';

/// Mixin that adds general helper functions to a [GameComponent].
///
/// Access all helper functions through the [util] API object:
/// ```dart
/// component.util.showDamage(10);
/// component.util.getDirectionToTarget(enemy);
/// ```
mixin WithUtil on Component {
  late final UtilApi util = UtilApi(this as GameComponent);
}
