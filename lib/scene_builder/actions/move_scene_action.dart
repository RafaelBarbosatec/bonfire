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
class MoveComponentSceneAction<T extends Movement> extends SceneAction {
  final T component;
  final Vector2 position;
  final double? speed;

  MoveComponentSceneAction(this.component, this.position, {this.speed});
  @override
  bool runAction(double dt, BonfireGameInterface game) {
    double diffX = (component.position.x - position.x).abs();
    double speedDt = (speed ?? component.speed) * dt;
    double speedX = speedDt > diffX ? diffX : (speed ?? component.speed);

    double diffY = (component.position.y - position.y).abs();
    double speedY = speedDt > diffY ? diffY : (speed ?? component.speed);

    bool canMoveX = true;
    bool canMoveY = true;
    if (component.position.x > position.x) {
      canMoveX = component.moveLeft(speedX);
    }
    if (component.position.x < position.x) {
      canMoveX = component.moveRight(speedX);
    }

    if (component.position.y > position.y) {
      canMoveY = component.moveUp(speedY);
    }

    if (component.position.y < position.y) {
      canMoveY = component.moveDown(speedY);
    }
    if (diffX <= speedDt && diffY <= speedDt) {
      component.idle();
      return true;
    }

    if (!canMoveY && !canMoveX) {
      component.idle();
      return true;
    }

    return false;
  }
}
