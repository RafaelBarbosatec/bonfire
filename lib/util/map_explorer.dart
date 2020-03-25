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
  }
}
