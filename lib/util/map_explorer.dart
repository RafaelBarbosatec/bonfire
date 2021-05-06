import 'package:bonfire/camera/camera.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:flame/extensions.dart';

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
      camera.moveUp(speed * 0.8);
      camera.moveTop(speed * 0.8);
    }
    if (event.directional == JoystickMoveDirectional.MOVE_UP_RIGHT) {
      camera.moveRight(speed * 0.8);
      camera.moveTop(speed * 0.8);
    }
    if (event.directional == JoystickMoveDirectional.MOVE_DOWN_LEFT) {
      camera.moveUp(speed * 0.8);
      camera.moveDown(speed * 0.8);
    }
    if (event.directional == JoystickMoveDirectional.MOVE_DOWN_RIGHT) {
      camera.moveRight(speed * 0.8);
      camera.moveDown(speed * 0.8);
    }
  }

  @override
  void moveTo(Vector2 position, List<Offset> path) {}
}
