import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/camera.dart';
import 'package:bonfire/util/game_component.dart';
import 'package:bonfire/util/game_interface.dart';
import 'package:bonfire/util/map_explorer.dart';
import 'package:bonfire/util/value_enerator.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/cupertino.dart';

class RPGGame extends BaseGame with TapDetector {
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

  @override
  void onTapDown(TapDownDetails details) {
    joystickController.onTapDownAction(details);
    components
        .where((item) => item is TapDetector)
        .forEach((item) => (item as TapDetector).onTapDown(details));
  }

  @override
  void onTapUp(TapUpDetails details) {
    joystickController.onTapUpAction(details);
    components
        .where((item) => item is TapDetector)
        .forEach((item) => (item as TapDetector).onTapUp(details));
  }

  @override
  void onTap() {
    components
        .where((item) => item is TapDetector)
        .forEach((item) => (item as TapDetector).onTap());
  }

  @override
  void onTapCancel() {
    joystickController.onTapCancelAction();
    components
        .where((item) => item is TapDetector)
        .forEach((item) => (item as TapDetector).onTapCancel());
  }

  void onPanStartLeftScreen(DragStartDetails details) {
    joystickController.onPanStart(details);
  }

  void onPanUpdateLeftScreen(DragUpdateDetails details) {
    joystickController.onPanUpdate(details);
  }

  void onPanEndLeftScreen(DragEndDetails details) {
    joystickController.onPanEnd(details);
  }

  void onTapDownLeftScreen(TapDownDetails details) {
    joystickController.onTapDown(details);
  }

  void onTapUpLeftScreen(TapUpDetails details) {
    joystickController.onTapUp(details);
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
