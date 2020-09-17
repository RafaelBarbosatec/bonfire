import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/base/rpg_game.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/game_interface/game_interface.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/tiled/tiled_world_data.dart';
import 'package:bonfire/tiled/tiled_world_map.dart';
import 'package:bonfire/util/game_controller.dart';
import 'package:flutter/material.dart';

class BonfireTiledWidget extends StatefulWidget {
  final JoystickController joystick;
  final Player player;
  final GameInterface interface;
  final GameComponent background;
  final bool constructionMode;
  final bool showCollisionArea;
  final bool showFPS;
  final GameController gameController;
  final Color constructionModeColor;
  final Color collisionAreaColor;
  final Color lightingColorGame;
  final TiledWorldMap map;
  final Widget progress;
  final double cameraZoom;
  final Size cameraSizeMovementWindow;
  final bool cameraMoveOnlyMapArea;
  final AnimatedSwitcherTransitionBuilder transitionBuilder;
  final Duration durationShowAnimation;

  const BonfireTiledWidget({
    Key key,
    this.map,
    this.joystick,
    this.player,
    this.interface,
    this.background,
    this.constructionMode = false,
    this.showCollisionArea = false,
    this.showFPS = false,
    this.gameController,
    this.constructionModeColor,
    this.collisionAreaColor,
    this.lightingColorGame,
    this.progress,
    this.cameraZoom,
    this.cameraMoveOnlyMapArea = false,
    this.cameraSizeMovementWindow = const Size(50, 50),
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.durationShowAnimation,
  }) : super(key: key);
  @override
  _BonfireTiledWidgetState createState() => _BonfireTiledWidgetState();
}

class _BonfireTiledWidgetState extends State<BonfireTiledWidget>
    with TickerProviderStateMixin {
  RPGGame _game;
  bool _loading = true;

  @override
  void didUpdateWidget(BonfireTiledWidget oldWidget) {
    if (widget.constructionMode) {
      if (widget.map == null) return;
      widget.map.build().then((value) {
        _game.map.updateTiles(value.map.tiles);

        _game.decorations().forEach((d) => d.remove());
        _game.enemies().forEach((e) => e.remove());

        value.components.forEach((d) => _game.addGameComponent(d));
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _loadGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.durationShowAnimation ?? Duration(milliseconds: 300),
      transitionBuilder: widget.transitionBuilder,
      child: _loading
          ? (widget.progress ??
              Center(
                child: CircularProgressIndicator(),
              ))
          : _game.widget,
    );
  }

  void _loadGame() async {
    TiledWorldData tiled;
    if (widget.map != null) {
      tiled = await widget.map.build();
    }

    _game = RPGGame(
      context: context,
      joystickController: widget.joystick,
      player: widget.player,
      interface: widget.interface,
      map: tiled?.map,
      components: tiled?.components ?? [],
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
    );
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {
      _loading = false;
    });
  }
}
