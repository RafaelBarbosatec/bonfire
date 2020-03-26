import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/camera.dart';

class MapExplorer implements JoystickListener {
  final Camera camera;

  MapExplorer(this.camera);

  @override
  void joystickAction(int action) {
    // TODO: implement joystickAction
  }

  @override
  void joystickChangeDirectional(JoystickMoveDirectional directional) {
    camera.moveCamera(5, directional);
    if (directional == JoystickMoveDirectional.MOVE_TOP_LEFT) {
      camera.moveLeft(4);
      camera.moveTop(4);
    }
    if (directional == JoystickMoveDirectional.MOVE_TOP_RIGHT) {
      camera.moveRight(4);
      camera.moveTop(4);
    }
    if (directional == JoystickMoveDirectional.MOVE_BOTTOM_LEFT) {
      camera.moveLeft(4);
      camera.moveBottom(4);
    }
    if (directional == JoystickMoveDirectional.MOVE_BOTTOM_RIGHT) {
      camera.moveRight(4);
      camera.moveBottom(4);
    }
  }
}
