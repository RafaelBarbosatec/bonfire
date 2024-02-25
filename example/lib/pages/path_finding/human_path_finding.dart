import 'package:bonfire/bonfire.dart';
import 'package:example/pages/player/simple/human.dart';

class HumanPathFinding extends HumanPlayer with PathFinding, TapGesture {
  HumanPathFinding({required Vector2 position}) : super(position: position) {
    setupPathFinding(pathLineStrokeWidth: 2);
  }

  @override
  void onTap() {}

  @override
  void onTapDownScreen(GestureEvent event) {
    moveToPositionWithPathFinding(event.worldPosition);
    super.onTapDownScreen(event);
  }
}
