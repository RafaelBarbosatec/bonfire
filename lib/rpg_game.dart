import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/base_game_point_detector.dart';
import 'package:bonfire/util/camera.dart';
import 'package:bonfire/util/game_component.dart';
import 'package:bonfire/util/game_controller.dart';
import 'package:bonfire/util/game_interface/game_interface.dart';
import 'package:bonfire/util/interval_tick.dart';
import 'package:bonfire/util/lighting/lighting.dart';
import 'package:bonfire/util/lighting/lighting_config.dart';
import 'package:bonfire/util/lighting/with_lighting.dart';
import 'package:bonfire/util/map_explorer.dart';
import 'package:bonfire/util/value_generator.dart';
import 'package:flame/components/component.dart';
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
  final JoystickController joystickController;
  final GameComponent background;
  final Camera gameCamera = Camera();
  final bool constructionMode;
  final bool showCollisionArea;
  final GameController gameController;
  final Color constructionModeColor;
  final Color lightingColorGame;
  final Color collisionAreaColor;
  IntervalTick _interval;

  RPGGame({
    @required this.context,
    @required this.vsync,
    @required this.map,
    @required this.joystickController,
    this.player,
    this.interface,
    List<Enemy> enemies,
    List<GameDecoration> decorations,
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
    gameCamera.gameRef = this;
    joystickController.joystickListener = player ?? MapExplorer(gameCamera);
    if (gameController != null) gameController.setGame(this);
    if (background != null) add(background);
    add(map);
    decorations?.forEach((decoration) => add(decoration));
    enemies?.forEach((enemy) => add(enemy));
    if (player != null) add(player);
    if (lightingColorGame != null) add(Lighting(color: lightingColorGame));
    if (interface != null) add(interface);
    add(joystickController);
    _interval = IntervalTick(200, tick: gameController?.notifyListeners);
  }

  @override
  void update(double t) {
    _interval.update(t);
    super.update(t);
  }

  @override
  void renderComponent(Canvas canvas, Component comp) {
    if (!comp.loaded()) {
      return;
    }
    canvas.save();
    if (!comp.isHud()) {
      canvas.translate(-gameCamera.position.x, -gameCamera.position.y);
    }
    comp.render(canvas);
    canvas.restore();
  }

  void addEnemy(Enemy enemy) {
    add(enemy);
  }

  void addDecoration(GameDecoration decoration) {
    add(decoration);
  }

  Iterable<Enemy> visibleEnemies() {
    return components
        .where((element) => (element is Enemy) && element.isVisibleInMap())
        .cast();
  }

  Iterable<Enemy> livingEnemies() {
    return components
        .where((element) => (element is Enemy) && !element.isDead)
        .cast();
  }

  Iterable<GameDecoration> visibleDecorations() {
    return components
        .where((element) =>
            (element is GameDecoration) && element.isVisibleInMap())
        .cast();
  }

  Iterable<Enemy> enemies() {
    return components.where((element) => (element is Enemy)).cast();
  }

  Iterable<GameDecoration> decorations() {
    return components.where((element) => (element is GameDecoration)).cast();
  }

  Iterable<LightingConfig> lightVisible() {
    return components
        .where((element) =>
            element is WithLighting &&
            (element as WithLighting).isVisible(gameCamera))
        .map((e) => (e as WithLighting).lightingConfig);
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
