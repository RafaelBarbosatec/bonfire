import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

class ExitMapSensor extends GameDecoration with Sensor<Player> {
  final String id;
  bool hasContact = false;
  final ValueChanged<String> exitMap;

  ExitMapSensor(this.id, Vector2 position, Vector2 size, this.exitMap)
      : super(
          position: position,
          size: size,
        );

  @override
  void onContact(Player component) {
    if (!hasContact) {
      hasContact = true;
      exitMap(id);
    }
    super.onContact(component);
  }
}
