import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:example/interface/bar_life_component.dart';
import 'package:example/player/knight.dart';

class KnightInterface extends GameInterface {
  @override
  void resize(Size size) {
    add(BarLifeComponent());
    add(InterfaceComponent(
      sprite: Sprite('blue_button1.png'),
      spriteSelected: Sprite('blue_button2.png'),
      height: 40,
      width: 40,
      id: 5,
      position: Position(150, 20),
      onTapComponent: () {
        if (gameRef.player != null) {
          (gameRef.player as Knight).showEmote();
        }
      },
    ));
    super.resize(size);
  }
}
