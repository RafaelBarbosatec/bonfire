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

  Iterable<Enemy> _enemies = List();
  Iterable<Enemy> _visibleEnemies = List();
  Iterable<Enemy> _livingEnemies = List();
  Iterable<GameDecoration> _decorations = List();
  Iterable<GameDecoration> _visibleDecorations = List();
  Iterable<LightingConfig> _lightToRender = List();
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

    _interval = IntervalTick(100, tick: _updateTempList);
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
    return _visibleEnemies;
  }

  Iterable<Enemy> livingEnemies() {
    return _livingEnemies;
  }

  Iterable<GameDecoration> visibleDecorations() {
    return _visibleDecorations;
  }

  Iterable<Enemy> enemies() {
    return _enemies;
  }

  Iterable<GameDecoration> decorations() {
    return _decorations;
  }

  Iterable<LightingConfig> lightVisible() {
    return _lightToRender;
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

  void _updateTempList() {
    _decorations =
        components.where((element) => (element is GameDecoration)).cast();
    _visibleDecorations =
        _decorations.where((element) => element.isVisibleInMap());

    _enemies = components.where((element) => (element is Enemy)).cast();
    _livingEnemies = _enemies.where((element) => !element.isDead).cast();
    _visibleEnemies =
        _livingEnemies.where((element) => element.isVisibleInMap());

    if (lightingColorGame != null) {
      _lightToRender = components
          .where((element) =>
              element is WithLighting &&
              (element as WithLighting).isVisible(size))
          .map((e) => (e as WithLighting).lightingConfig);
    }

    if (gameController != null) gameController.notifyListeners();
  }
}
