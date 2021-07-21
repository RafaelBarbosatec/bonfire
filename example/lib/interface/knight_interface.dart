import 'package:bonfire/bonfire.dart';
import 'package:example/interface/bar_life_component.dart';
import 'package:example/player/knight.dart';
import 'package:flutter/material.dart';

class KnightInterface extends GameInterface {
  @override
  Future<void> onLoad() {
    add(BarLifeComponent());
    add(InterfaceComponent(
      sprite: Sprite.load('blue_button1.png'),
      spriteSelected: Sprite.load('blue_button2.png'),
      height: 40,
      width: 40,
      id: 5,
      position: Vector2(150, 20),
      onTapComponent: (selected) {
        final player = gameRef.player;
        if (player != null) {
          (player as Knight).showEmote();
        }
      },
    ));
    add(InterfaceComponent(
      sprite: Sprite.load('blue_button1.png'),
      spriteSelected: Sprite.load('blue_button2.png'),
      height: 40,
      width: 40,
      id: 5,
      position: Vector2(200, 20),
      onTapComponent: (selected) {
        if (gameRef.player != null) {
          (gameRef.player as Knight).changeControllerToVisibleEnemy();
        }
      },
    ));
    add(TextInterfaceComponent(
      text: 'Text example',
      textConfig: TextPaintConfig(
        color: Colors.white,
      ),
      id: 5,
      position: Vector2(250, 20),
      onTapComponent: (selected) {
        if (gameRef.player != null) {
          (gameRef.player as Knight).showEmote();
        }
      },
    ));
    return super.onLoad();
  }
}
