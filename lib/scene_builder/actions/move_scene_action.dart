import 'package:bonfire/base/bonfire_game_interface.dart';
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
/// on 04/03/22

/// SceneAction that move the componente in the game.
class MoveComponentSceneAction<T extends Movement> extends SceneAction {
  final T component;
  final Vector2 newPosition;
  final double? speed;

  MoveComponentSceneAction({
    dynamic id,
    required this.component,
    required this.newPosition,
    this.speed,
  }) : super(id);

  @override
  bool runAction(double dt, BonfireGameInterface game) {
    double diffX = (component.position.x - newPosition.x).abs();
    double speedDt = (speed ?? component.speed) * dt;
    double speedX = speedDt > diffX ? diffX : (speed ?? component.speed);

    double diffY = (component.position.y - newPosition.y).abs();
    double speedY = speedDt > diffY ? diffY : (speed ?? component.speed);

    bool canMoveX = false;
    bool canMoveY = false;
    if (component.position.x > newPosition.x) {
      canMoveX = component.moveLeft(speedX);
    }
    if (component.position.x < newPosition.x) {
      canMoveX = component.moveRight(speedX);
    }

    if (component.position.y > newPosition.y) {
      canMoveY = component.moveUp(speedY);
    }

    if (component.position.y < newPosition.y) {
      canMoveY = component.moveDown(speedY);
    }

    if (diffX <= speedDt) {
      canMoveX = false;
    }

    if (diffY <= speedDt) {
      canMoveY = false;
    }

    if (!canMoveY && !canMoveX) {
      component.idle();
      return true;
    }

    return false;
  }
}
