import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/base_game_point_detector.dart';
import 'package:bonfire/util/camera.dart';
import 'package:bonfire/util/game_component.dart';
import 'package:bonfire/util/game_controller.dart';
import 'package:bonfire/util/game_intercafe/game_interface.dart';
import 'package:bonfire/util/lighting/lighting.dart';
import 'package:bonfire/util/map_explorer.dart';
import 'package:bonfire/util/value_generator.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RPGGame extends BaseGamePointerDetector with KeyboardEvents {
  final BuildContext context;
  final TickerProvider vsync;
  final Player player;
  final GameInterface interface;
  final MapGame map;
  final List<Enemy> enemies;
  final List<GameDecoration> decorations;
  final JoystickController joystickController;
  final GameComponent background;
  final Camera gameCamera = Camera();
  final bool constructionMode;
  final bool showCollisionArea;
  final GameController gameController;
  final Color constructionModeColor;
  final Color lightingColorGame;
  final Color collisionAreaColor;

  RPGGame({
    @required this.context,
    @required this.vsync,
    @required this.map,
    @required this.joystickController,
    this.player,
    this.interface,
    this.enemies,
    this.decorations,
    this.background,
    this.constructionMode = false,
    this.showCollisionArea = false,
    this.gameController,
    this.constructionModeColor,
    this.collisionAreaColor,
    this.lightingColorGame,
  })  : assert(map != null),
        assert(context != null),
        assert(joystickController != null) {
    if (gameController != null) gameController.setGame(this);
    gameCamera.gameRef = this;
    joystickController.joystickListener = player ?? MapExplorer(gameCamera);
    if (background != null) add(background);
    add(map);
    decorations?.forEach((decoration) => add(decoration));
    enemies?.forEach((enemy) => add(enemy));
    if (player != null) add(player);
    if (lightingColorGame != null) add(Lighting(color: lightingColorGame));
    add(joystickController);
    if (interface != null) add(interface);
  }

  @override
  void update(double t) {
    super.update(t);
    enemies.removeWhere((enemy) => enemy.destroy());
    decorations.removeWhere((enemy) => enemy.destroy());
    if (gameController != null) gameController.notifyListeners();
  }

  void addEnemy(Enemy enemy) {
    enemies.add(enemy);
    add(enemy);
  }

  void addDecoration(GameDecoration decoration) {
    decorations.add(decoration);
    add(decoration);
  }

  Iterable<Enemy> visibleEnemies() {
    return enemies.where((enemy) => enemy.isVisibleInMap());
  }

  Iterable<Enemy> livingEnemies() {
    return enemies.where((enemy) => !enemy.isDead);
  }

  Iterable<GameDecoration> visibleDecorations() {
    return decorations.where((decoration) => decoration.isVisibleInMap());
  }

  ValueGenerator getValueGenerator(
    Duration duration, {
    double begin = 0.0,
    double end = 1.0,
  }) {
    return ValueGenerator(
      vsync,
      duration,
      end: end,
      begin: begin,
    );
  }

  @override
  void onKeyEvent(RawKeyEvent event) {
    joystickController.onKeyboard(event);
  }
}
