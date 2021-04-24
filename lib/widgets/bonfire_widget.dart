import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/base/custom_game_widget.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/camera/camera_config.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/game_interface/game_interface.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/game_color_filter.dart';
import 'package:bonfire/util/game_controller.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BonfireWidget extends StatefulWidget {
  /// The player-controlling component.
  final JoystickController? joystick;

  /// Represents the character controlled by the user in the game. Instances of this class has actions and movements ready to be used and configured.
  final Player? player;

  /// The way you cand raw things like life bars, stamina and settings. In another words, anything that you may add to the interface to the game.
  final GameInterface? interface;

  /// Represents a map (or world) where the game occurs.
  final MapGame map;

  /// Used to show grid in the map and facilitate the construction and testing of the map
  final bool constructionMode;

  /// Used to draw area collision in objects.
  final bool showCollisionArea;

  /// Used to show in the interface the FPS.
  final bool showFPS;

  /// Color grid when `constructionMode` is true
  final Color? constructionModeColor;

  /// Color of the collision area when `showCollisionArea` is true
  final Color? collisionAreaColor;

  /// Used to configure lighting in the game
  final Color? lightingColorGame;

  final Map<String, OverlayWidgetBuilder<BonfireGame>>? overlayBuilderMap;
  final List<String>? initialActiveOverlays;
  final List<Enemy>? enemies;
  final List<GameDecoration>? decorations;
  final List<GameComponent>? components;
  final GameComponent? background;
  final GameController? gameController;
  final CameraConfig? cameraConfig;
  final GameColorFilter? colorFilter;

  const BonfireWidget({
    Key? key,
    required this.map,
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
    this.colorFilter,
    this.components,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
    this.cameraConfig,
  }) : super(key: key);

  @override
  _BonfireWidgetState createState() => _BonfireWidgetState();
}

class _BonfireWidgetState extends State<BonfireWidget> {
  late BonfireGame _game;

  @override
  void didUpdateWidget(BonfireWidget oldWidget) {
    if (widget.constructionMode) {
      _refreshGame();
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
      cameraConfig: widget.cameraConfig,
      colorFilter: widget.colorFilter,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomGameWidget(
      game: _game,
      overlayBuilderMap: widget.overlayBuilderMap,
      initialActiveOverlays: widget.initialActiveOverlays,
    );
  }

  void _refreshGame() async {
    await _game.map.updateTiles(widget.map.tiles);

    _game.decorations().forEach((d) => d.remove());
    widget.decorations?.forEach((d) => _game.addGameComponent(d));

    _game.enemies().forEach((e) => e.remove());
    widget.enemies?.forEach((e) => _game.addGameComponent(e));
  }
}
