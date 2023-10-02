import 'package:bonfire/bonfire.dart';
import 'package:example/pages/player/simple/human.dart';

class HumanWithCollision extends HumanPlayer with BlockMovementCollision {
  HumanWithCollision({required Vector2 position}) : super(position: position);

  @override
  Future<void> onLoad() {
    /// Adds rectangle collision
    add(RectangleHitbox(size: size / 2, position: size / 4));
    return super.onLoad();
  }
}
