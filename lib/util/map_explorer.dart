import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/camera.dart';

class MapExplorer implements JoystickListener {
  final Camera camera;

  MapExplorer(this.camera);

  @override
  void joystickAction(int action) {}

  @override
  void joystickChangeDirectional(
      JoystickMoveDirectional directional, double intensity, double radAngle) {
    double speed = 8 * intensity;
    camera.moveCamera(speed, directional);
    if (directional == JoystickMoveDirectional.MOVE_TOP_LEFT) {
      camera.moveLeft(speed * 0.8);
      camera.moveTop(speed * 0.8);
    }
    if (directional == JoystickMoveDirectional.MOVE_TOP_RIGHT) {
      camera.moveRight(speed * 0.8);
      camera.moveTop(speed * 0.8);
    }
    if (directional == JoystickMoveDirectional.MOVE_BOTTOM_LEFT) {
      camera.moveLeft(speed * 0.8);
      camera.moveBottom(speed * 0.8);
    }
    if (directional == JoystickMoveDirectional.MOVE_BOTTOM_RIGHT) {
      camera.moveRight(speed * 0.8);
      camera.moveBottom(speed * 0.8);
    }
  }
}
