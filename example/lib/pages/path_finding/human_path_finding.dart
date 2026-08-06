import 'package:bonfire/bonfire.dart';
import 'package:example/pages/player/simple/human.dart';

class HumanPathFinding extends HumanPlayer with WithPathFinding, TapGesture {
  HumanPathFinding({required Vector2 position}) : super(position: position) {
    pathFinding.setup(
      pathLineStrokeWidth: 2,
      useOnlyVisibleBarriers: false,
    );
  }

  @override
  void onTap() {}

  @override
  void onTapDownScreen(GestureEvent event) {
    pathFinding.moveToPosition(event.worldPosition);
    super.onTapDownScreen(event);
  }
}
