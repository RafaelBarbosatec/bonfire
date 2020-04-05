import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/base_game_point_detector.dart';
import 'package:bonfire/util/camera.dart';
import 'package:bonfire/util/game_component.dart';
import 'package:bonfire/util/game_interface.dart';
import 'package:bonfire/util/map_explorer.dart';
import 'package:bonfire/util/value_generator.dart';
import 'package:flutter/cupertino.dart';

class RPGGame extends BaseGamePointerDetector {
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
  Function(RPGGame) _gameListener;

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
  })  : assert(map != null),
        assert(context != null),
        assert(joystickController != null) {
    gameCamera.gameRef = this;
    joystickController.joystickListener = player ?? MapExplorer(gameCamera);
    if (background != null) add(background);
    add(map);
    decorations?.forEach((decoration) => add(decoration));
    enemies?.forEach((enemy) => add(enemy));
    if (player != null) add(player);
    add(joystickController);
    if (interface != null) add(interface);
  }

  @override
  void update(double t) {
    super.update(t);
    if (_gameListener != null) _gameListener(this);
  }

  void addListener(Function(RPGGame) gameListener) {
    this._gameListener = gameListener;
  }

  void addEnemy(Enemy enemy) {
    enemies.add(enemy);
    add(enemy);
  }

  void addDecoration(GameDecoration decoration) {
    decorations.add(decoration);
    add(decoration);
  }

  void onPointerDown(PointerDownEvent event) {
    joystickController.onPointerDown(event);
    super.onPointerDown(event);
  }

  void onPointerMove(PointerMoveEvent event) {
    joystickController.onPointerMove(event);
    super.onPointerMove(event);
  }

  void onPointerUp(PointerUpEvent event) {
    joystickController.onPointerUp(event);
    super.onPointerUp(event);
  }

  void onPointerCancel(PointerCancelEvent event) {
    joystickController.onPointerCancel(event);
    super.onPointerCancel(event);
  }

  List<Enemy> visibleEnemies() {
    return enemies.where((enemy) => enemy.isVisibleInMap()).toList();
  }

  List<GameDecoration> visibleDecorations() {
    return decorations
        .where((decoration) => decoration.isVisibleInMap())
        .toList();
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
}
