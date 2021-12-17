import 'package:bonfire/base/game_component.dart';
import 'package:flame/components.dart';

abstract class FollowerObject extends GameComponent {
  final GameComponent target;
  final Vector2? positionFromTarget;

  FollowerObject(
    this.target,
    this.positionFromTarget,
    Vector2 size,
  ) {
    this.size = size;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final newPosition = positionFromTarget ?? Vector2.zero();
    this.position = target.position +
        Vector2(
          newPosition.x,
          newPosition.y,
        );
  }

  @override
  int get priority => target.priority;
}
