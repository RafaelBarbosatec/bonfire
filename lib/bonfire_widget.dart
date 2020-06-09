import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/tiled/tiled_world_map.dart';
import 'package:bonfire/util/game_component.dart';
import 'package:bonfire/util/game_controller.dart';
import 'package:bonfire/util/game_interface/game_interface.dart';
import 'package:flutter/material.dart';

class BonfireWidget extends StatefulWidget {
  final JoystickController joystick;
  final Player player;
  final GameInterface interface;
  final MapGame map;
  final List<Enemy> enemies;
  final List<GameDecoration> decorations;
  final GameComponent background;
  final bool constructionMode;
  final bool showCollisionArea;
  final bool showFPS;
  final GameController gameController;
  final Color constructionModeColor;
  final Color collisionAreaColor;
  final Color lightingColorGame;
  final TiledWorldMap tiledMap;

  const BonfireWidget({
    Key key,
    @required this.joystick,
    @required this.map,
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
    this.tiledMap,
  }) : super(key: key);

  @override
  _BonfireWidgetState createState() => _BonfireWidgetState();
}

class _BonfireWidgetState extends State<BonfireWidget>
    with TickerProviderStateMixin {
  RPGGame _game;
  List<Enemy> _enemies;
  List<GameDecoration> _decorations;
  MapGame _map;
  bool _loading = true;

  @override
  void didUpdateWidget(BonfireWidget oldWidget) {
    if (widget.constructionMode && widget.tiledMap == null) {
      if (_game.map != null) _game.map.updateTiles(widget.map.tiles);

      _game.decorations().forEach((d) => d.remove());
      if (widget.decorations != null)
        widget.decorations.forEach((d) => _game.addDecoration(d));

      _game.enemies().forEach((e) => e.remove());
      if (widget.enemies != null)
        widget.enemies.forEach((e) => _game.addEnemy(e));
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _enemies = widget.enemies ?? [];
    _decorations = widget.decorations ?? [];
    _map = widget.map;
    _loadGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : _game.widget;
  }

  void _loadGame() async {
    if (widget.tiledMap != null) {
      final tiled = await widget.tiledMap.build();
      _map = tiled.map;
      _enemies.addAll(tiled.enemies);
      _decorations.addAll(tiled.decorations);
    }

    _game = RPGGame(
      context: context,
      vsync: this,
      joystickController: widget.joystick,
      player: widget.player,
      interface: widget.interface,
      map: _map,
      decorations: _decorations,
      enemies: _enemies,
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
    );
    setState(() {
      _loading = false;
    });
  }
}
