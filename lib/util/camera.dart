import 'package:bonfire/bonfire.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

class Camera with HasGameRef<RPGGame> {
  double maxTop = 0;
  double maxLeft = 0;
  Position position = Position.empty();

  bool isMaxBottom() {
    return (position.y * -1) >= maxTop;
  }

  bool isMaxLeft() {
    return position.x == 0;
  }

  bool isMaxRight() {
    return (position.x * -1) >= maxLeft;
  }

  bool isMaxTop() {
    return position.y == 0;
  }

  void moveToPosition(Position position) {
    double distanceLeft = gameRef.size.width / 2;
    double distanceTop = gameRef.size.height / 2;

    double positionLeftCamera = position.x - distanceLeft;
    double positionTopCamera = position.y - distanceTop;
    print('$maxLeft / $maxTop');
    print('$positionLeftCamera / $positionTopCamera');

    if (positionLeftCamera > maxLeft) positionLeftCamera = maxLeft;

    positionLeftCamera *= -1;
    if (positionLeftCamera > 0) positionLeftCamera = 0;

    if (positionTopCamera * -1 > maxTop) positionTopCamera = maxTop;
    positionTopCamera *= -1;
    if (positionTopCamera > 0) positionTopCamera = 0;

    print('$positionLeftCamera / $positionTopCamera');

    this.position.x = positionLeftCamera;
    this.position.y = positionTopCamera;
  }
}
