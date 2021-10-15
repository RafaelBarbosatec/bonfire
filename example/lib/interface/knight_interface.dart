import 'package:bonfire/bonfire.dart';
import 'package:example/interface/bar_life_component.dart';
import 'package:example/player/knight.dart';
import 'package:flutter/material.dart';

class KnightInterface extends GameInterface {
  static const followerWidgetTestId = 'BUTTON';

  @override
  void onMount() {
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
      selectable: true,
      onTapComponent: (selected) {
        if (gameRef.player != null) {
          (gameRef.player as Knight).changeControllerToVisibleEnemy();
        }
      },
    ));
    add(InterfaceComponent(
      sprite: Sprite.load('blue_button1.png'),
      spriteSelected: Sprite.load('blue_button2.png'),
      height: 40,
      width: 40,
      id: 5,
      position: Vector2(250, 20),
      selectable: true,
      onTapComponent: (selected) {
        if (!selected && FollowerWidget.isVisible(followerWidgetTestId)) {
          FollowerWidget.remove(followerWidgetTestId);
          return;
        }
        gameRef.player?.let((player) {
          FollowerWidget.show(
            identify: followerWidgetTestId,
            context: context,
            target: player,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  print('aqui');
                },
                child: Text('clica aqui'),
              ),
            ),
            align: Offset(0, -55),
          );
        });
      },
    ));
    add(TextInterfaceComponent(
      text: 'Text example',
      textConfig: TextPaintConfig(
        color: Colors.white,
      ),
      id: 5,
      position: Vector2(300, 20),
      onTapComponent: (selected) {
        if (gameRef.player != null) {
          (gameRef.player as Knight).showEmote();
        }
      },
    ));
    super.onMount();
  }
}
