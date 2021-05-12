import 'dart:ui';

abstract class ComponentMovement {
  void moveUp(double speed, {VoidCallback? onCollision});
  void moveDown(double speed, {VoidCallback? onCollision});
  void moveLeft(double speed, {VoidCallback? onCollision});
  void moveRight(double speed, {VoidCallback? onCollision});
  void moveUpRight(double speedX, double speedY, {VoidCallback? onCollision});
  void moveUpLeft(double speedX, double speedY, {VoidCallback? onCollision});
  void moveDownLeft(double speedX, double speedY, {VoidCallback? onCollision});
  void moveDownRight(double speedX, double speedY, {VoidCallback? onCollision});
  void idle();
}
