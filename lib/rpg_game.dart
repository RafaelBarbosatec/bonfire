import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/game_interface.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flutter/cupertino.dart';

class RPGGame extends BaseGame with TapDetector {
  final BuildContext context;
  final Player player;
  final GameInterface interface;
  final MapGame map;
  final List<Enemy> enemies;
  final List<GameDecoration> decorations;
  final JoystickController joystickController;
  Position mapCamera = Position.empty();
  Function(RPGGame) _gameListener;

  RPGGame({
    @required this.context,
    @required this.player,
    @required this.map,
    @required this.joystickController,
    this.interface,
    this.enemies,
    this.decorations,
  })  : assert(player != null),
        assert(map != null),
        assert(context != null),
        assert(joystickController != null) {
    joystickController.joystickListener = player;

    add(map);
    decorations?.forEach((decoration) => add(decoration));
    enemies?.forEach((enemy) => add(enemy));
    add(player);
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
}
