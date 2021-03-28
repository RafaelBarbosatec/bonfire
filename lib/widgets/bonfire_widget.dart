import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/game_interface/game_interface.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/game_color_filter.dart';
import 'package:bonfire/util/game_controller.dart';
import 'package:flutter/material.dart';

class BonfireWidget extends StatefulWidget {
  final JoystickController joystick;
  final Player player;
  final GameInterface interface;
  final MapGame map;
  final List<Enemy> enemies;
  final List<GameDecoration> decorations;
  final List<GameComponent> components;
  final GameComponent background;
  final bool constructionMode;
  final bool showCollisionArea;
  final bool showFPS;
  final GameController gameController;
  final Color constructionModeColor;
  final Color collisionAreaColor;
  final Color lightingColorGame;
  final double cameraZoom;
  final Size cameraSizeMovementWindow;
  final bool cameraMoveOnlyMapArea;
  final GameColorFilter colorFilter;

  const BonfireWidget({
    Key key,
    this.map,
    this.joystick,
    this.player,
    this.interface,
    this.enemies,
    this.decorations,
    this.gameController,
    this.background,
    this.constructionMode = false,
    this.showCollisionArea = false,
    this.showFPS = false,
    this.constructionModeColor,
    this.collisionAreaColor,
    this.lightingColorGame,
    this.cameraZoom,
    this.colorFilter,
    this.cameraMoveOnlyMapArea = false,
    this.cameraSizeMovementWindow = const Size(50, 50),
    this.components,
  }) : super(key: key);

  @override
  _BonfireWidgetState createState() => _BonfireWidgetState();
}

class _BonfireWidgetState extends State<BonfireWidget> {
  BonfireGame _game;

  @override
  void didUpdateWidget(BonfireWidget oldWidget) {
    if (widget.constructionMode) {
      if (_game.map != null) _game.map.updateTiles(widget.map.tiles);

      _game.decorations().forEach((d) => d.remove());
      if (widget.decorations != null)
        widget.decorations.forEach((d) => _game.addGameComponent(d));

      _game.enemies().forEach((e) => e.remove());
      if (widget.enemies != null)
        widget.enemies.forEach((e) => _game.addGameComponent(e));
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _game = BonfireGame(
      context: context,
      joystickController: widget.joystick,
      player: widget.player,
      interface: widget.interface,
      map: widget.map,
      decorations: widget.decorations,
      enemies: widget.enemies,
      components: widget.components ?? [],
      background: widget.background,
      constructionMode: widget.constructionMode,
      showCollisionArea: widget.showCollisionArea,
      showFPS: widget.showFPS,
      gameController: widget.gameController,
      constructionModeColor:
          widget.constructionModeColor ?? Colors.cyan.withOpacity(0.5),
      collisionAreaColor:
          widget.collisionAreaColor ?? Colors.lightGreenAccent.withOpacity(0.5),
      lightingColorGame: widget.lightingColorGame,
      cameraZoom: widget.cameraZoom,
      cameraSizeMovementWindow: widget.cameraSizeMovementWindow,
      cameraMoveOnlyMapArea: widget.cameraMoveOnlyMapArea,
      colorFilter: widget.colorFilter,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _game.widget;
  }
}
