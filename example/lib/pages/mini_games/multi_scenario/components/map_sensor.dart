import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/multi_scenario/maps.dart';

class MapSensor extends GameDecoration with Sensor<Player> {
  final String id;
  bool hasContact = false;
  final String targetMap;
  final Vector2 playerPosition;
  final Direction playerDirection;

  MapSensor(
    this.id,
    Vector2 position,
    Vector2 size,
    this.targetMap,
    this.playerPosition,
    this.playerDirection,
  ) : super(
          position: position,
          size: size,
        );

  @override
  void onContact(Player component) {
    if (!hasContact) {
      hasContact = true;
      MapNavigator.of(context).toNamed(
        targetMap,
        arguments: MapArguments(
          playerPosition,
          playerDirection,
        ),
      );
    }
    super.onContact(component);
  }
}
