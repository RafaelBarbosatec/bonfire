import 'package:bonfire/bonfire.dart';
import 'package:example/shared/enemy/goblin.dart';
import 'package:example/shared/interface/bar_life_component.dart';
import 'package:example/shared/player/knight.dart';
import 'package:flutter/material.dart';

class KnightInterface extends GameInterface {
  static const followerWidgetTestId = 'BUTTON';
  Goblin? enemyControlled;

  @override
  void onMount() async {
    await add(BarLifeInterface());
    await add(InterfaceComponent(
      spriteUnselected: Sprite.load('blue_button1.png'),
      spriteSelected: Sprite.load('blue_button2.png'),
      size: Vector2(40, 40),
      id: 5,
      position: Vector2(150, 20),
      onTapComponent: (selected) {
        final player = gameRef.player;
        if (player != null) {
          (player as Knight).execShowEmote();
        }
      },
    ));
    await add(InterfaceComponent(
      spriteUnselected: Sprite.load('blue_button1.png'),
      spriteSelected: Sprite.load('blue_button2.png'),
      size: Vector2(40, 40),
      id: 5,
      position: Vector2(200, 20),
      selectable: true,
      onTapComponent: (selected) {
        changeControllerToVisibleEnemy();
      },
    ));
    await add(InterfaceComponent(
      spriteUnselected: Sprite.load('blue_button1.png'),
      spriteSelected: Sprite.load('blue_button2.png'),
      size: Vector2(40, 40),
      id: 5,
      position: Vector2(250, 20),
      selectable: true,
      onTapComponent: (selected) {
        _addFollowerWidgetExample(selected);
      },
    ));
    await add(InterfaceComponent(
      spriteUnselected: Sprite.load('blue_button1.png'),
      spriteSelected: Sprite.load('blue_button2.png'),
      size: Vector2(40, 40),
      id: 5,
      position: Vector2(300, 20),
      selectable: false,
      onTapComponent: (selected) {
        _animateColorFilter();
        {}
      },
    ));
    await add(TextInterfaceComponent(
      text: 'Start scene',
      textConfig: const TextStyle(
        color: Colors.white,
      ),
      id: 5,
      position: Vector2(350, 20),
      onTapComponent: (selected) {
        _startSceneExample();
      },
    ));
    super.onMount();
  }

  void changeControllerToVisibleEnemy() {
    if (hasGameRef) {
      if (enemyControlled == null) {
        final v = gameRef.visibles<Goblin>();
        if (v.isNotEmpty) {
          enemyControlled = v.first;
          enemyControlled?.enableBehaviors = false;
          gameRef.camera.moveToTargetAnimated(
            target: enemyControlled!,
            effectController: EffectController(
              duration: 0.5,
              curve: Curves.easeInOut,
            ),
            zoom: 2,
            onComplete: () {
              gameRef.addJoystickObserver(
                enemyControlled!,
                cleanObservers: true,
                moveCameraToTarget: true,
              );
            },
          );
        }
      } else if (gameRef.player != null) {
        gameRef.camera.moveToTargetAnimated(
          target: gameRef.player!,
          effectController: EffectController(
            duration: 0.5,
            curve: Curves.easeInOut,
          ),
          zoom: 1,
          onComplete: () {
            gameRef.addJoystickObserver(
              gameRef.player!,
              cleanObservers: true,
              moveCameraToTarget: true,
            );
            enemyControlled?.enableBehaviors = true;
            enemyControlled = null;
          },
        );
      }
    }
  }

  void _showDialogTest(VoidCallback completed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('AwaitCallbackSceneAction test'),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      completed();
                    },
                    child: const Text('CONTINUE'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      gameRef.stopScene();
                    },
                    child: const Text('STOP SCENE'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startSceneExample() {
    final enemiesVisible = gameRef.enemies(onlyVisible: true);
    if (gameRef.player != null && enemiesVisible.isNotEmpty) {
      final enemy = enemiesVisible.first;
      double initialZoom = gameRef.camera.zoom;
      gameRef.startScene([
        CameraSceneAction.position(Vector2(800, 800)),
        CameraSceneAction.target(gameRef.player!),
        CameraSceneAction.target(enemy, zoom: 2),
        DelaySceneAction(const Duration(seconds: 2)),
        MoveComponentSceneAction(
          component: enemy,
          newPosition: enemy.position.clone()..add(Vector2(-40, -10)),
        ),
        CameraSceneAction.target(gameRef.player!, zoom: initialZoom),
        AwaitCallbackSceneAction(
          completedCallback: (completed) {
            _showDialogTest(completed);
          },
        ),
        MoveComponentSceneAction(
          component: gameRef.player!,
          newPosition: gameRef.player!.position.clone()..add(Vector2(0, -20)),
        ),
        MoveComponentSceneAction(
          component: gameRef.player!,
          newPosition: gameRef.player!.position.clone()..add(Vector2(50, -20)),
        ),
        CameraSceneAction.target(enemy),
        CameraSceneAction.position(Vector2(200, 200)),
        CameraSceneAction.position(Vector2(0, 200)),
        CameraSceneAction.target(gameRef.player!),
      ]);
    }
  }

  void _addFollowerWidgetExample(bool selected) {
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              // ignore: avoid_print
              print('Tapped');
            },
            child: const Text('Tap here'),
          ),
        ),
      );
    });
  }

  void _animateColorFilter() {
    if (gameRef.colorFilter?.config.color == null) {
      gameRef.colorFilter?.animateTo(
        Colors.red.withOpacity(0.5),
      );
    } else {
      gameRef.colorFilter?.animateTo(Colors.transparent, onFinish: () {
        gameRef.colorFilter?.config.color = null;
      });
    }
  }
}
