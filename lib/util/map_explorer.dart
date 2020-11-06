import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/camera/camera.dart';
import 'package:flame/position.dart';

class MapExplorer implements JoystickListener {
  final Camera camera;

  MapExplorer(this.camera);

  @override
  void joystickAction(JoystickActionEvent event) {}

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    double speed = 8 * event.intensity;
    camera.moveCamera(speed, event.directional);
    if (event.directional == JoystickMoveDirectional.MOVE_UP_LEFT) {
      camera.moveLeft(speed * 0.8);
      camera.moveTop(speed * 0.8);
    }
    if (event.directional == JoystickMoveDirectional.MOVE_UP_RIGHT) {
      camera.moveRight(speed * 0.8);
      camera.moveTop(speed * 0.8);
    }
    if (event.directional == JoystickMoveDirectional.MOVE_DOWN_LEFT) {
      camera.moveLeft(speed * 0.8);
      camera.moveBottom(speed * 0.8);
    }
    if (event.directional == JoystickMoveDirectional.MOVE_DOWN_RIGHT) {
      camera.moveRight(speed * 0.8);
      camera.moveBottom(speed * 0.8);
    }
  }

  @override
  void moveTo(Position position) {}
}
