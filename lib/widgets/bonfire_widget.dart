import 'package:bonfire/background/game_background.dart';
import 'package:bonfire/base/bonfire_collision_config.dart';
import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/base/bonfire_quad_tree_collision.dart';
import 'package:bonfire/base/bonfire_with_collision.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/base/listener_game_widget.dart';
import 'package:bonfire/camera/camera_config.dart';
import 'package:bonfire/color_filter/game_color_filter.dart';
import 'package:bonfire/forces/forces_2d.dart';
import 'package:bonfire/game_interface/game_interface.dart';
import 'package:bonfire/input/player_controller.dart';
import 'package:bonfire/map/base/game_map.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/extensions/color_extensions.dart';
import 'package:flutter/material.dart';

class BonfireWidget extends StatefulWidget {
  /// Controls the player in the game. You can pass a list of controllers to control the player in different ways.
  final List<PlayerController>? playerControllers;

  /// Represents the character controlled by the user in the game. Instances of this class has actions and movements ready to be used and configured.
  final Player? player;

  /// The way you cand raw things like life bars, stamina and settings. In another words, anything that you may add to the interface to the game.
  final GameInterface? interface;

  /// Represents a map (or world) where the game occurs.
  final GameMap map;

  /// Used to show grid in the map and facilitate the construction and testing of the map
  final bool debugMode;

  /// Used to draw area collision in objects.
  final bool showCollisionArea;

  /// Color of the collision area when `showCollisionArea` is true
  final Color? collisionAreaColor;

  /// Used to configure lighting in the game
  final Color? lightingColorGame;

  final Color? backgroundColor;

  /// The [FocusNode] to control the games focus to receive event inputs.
  /// If omitted, defaults to an internally controlled focus node.
  final FocusNode? focusNode;

  /// Whether the [focusNode] requests focus once the game is mounted.
  /// Defaults to true.
  final bool autofocus;

  /// Initial mouse cursor for this [GameWidget]
  /// mouse cursor can be changed in runtime using [Game.mouseCursor]
  final MouseCursor? mouseCursor;

  final ValueChanged<BonfireGameInterface>? onReady;
  final Map<String, OverlayWidgetBuilder<BonfireGame>>? overlayBuilderMap;
  final List<String>? initialActiveOverlays;
  final List<GameComponent>? components;
  final List<GameComponent>? hudComponents;
  final GameBackground? background;
  final CameraConfig? cameraConfig;
  final GameColorFilter? colorFilter;
  final VoidCallback? onDispose;
  final List<Force2D>? globalForces;
  final BonfireCollisionConfig? collisionConfig;

  const BonfireWidget({
    required this.map,
    super.key,
    this.playerControllers,
    this.player,
    this.interface,
    this.background,
    this.debugMode = false,
    this.showCollisionArea = false,
    this.collisionAreaColor,
    this.lightingColorGame,
    this.backgroundColor,
    this.colorFilter,
    this.hudComponents,
    this.components,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
    this.cameraConfig,
    this.onReady,
    this.focusNode,
    this.autofocus = true,
    this.mouseCursor,
    this.onDispose,
    this.globalForces,
    this.collisionConfig,
  });

  @override
  BonfireWidgetState createState() => BonfireWidgetState();
}

class BonfireWidgetState extends State<BonfireWidget> {
  late BonfireGame _game;
  late BonfireCollisionConfig _collisionConfig;

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  void initState() {
    _collisionConfig =
        widget.collisionConfig ?? BonfireCollisionConfig.dafault();
    _buildGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenerGameWidget(
      game: _game,
      overlayBuilderMap: widget.overlayBuilderMap,
      initialActiveOverlays: widget.initialActiveOverlays,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: widget.mouseCursor,
    );
  }

  void _buildGame() {
    _game = _collisionConfig.when(
      defaultCollision: (c) => BonfireWithCollision(
        configDefault: c,
        context: context,
        playerControllers: widget.playerControllers,
        player: widget.player,
        interface: widget.interface,
        map: widget.map,
        components: widget.components,
        hudComponents: widget.hudComponents,
        background: widget.background,
        backgroundColor: widget.backgroundColor,
        debugMode: widget.debugMode,
        showCollisionArea: widget.showCollisionArea,
        collisionAreaColor: widget.collisionAreaColor ??
            Colors.lightGreenAccent.setOpacity(0.5),
        lightingColorGame: widget.lightingColorGame,
        cameraConfig: widget.cameraConfig,
        colorFilter: widget.colorFilter,
        onReady: widget.onReady,
        globalForces: widget.globalForces,
      ),
      quadTreeCollision: (c) => BonfireQuadTreeCollision(
        configQuadTree: c,
        context: context,
        playerControllers: widget.playerControllers,
        player: widget.player,
        interface: widget.interface,
        map: widget.map,
        components: widget.components,
        hudComponents: widget.hudComponents,
        background: widget.background,
        backgroundColor: widget.backgroundColor,
        debugMode: widget.debugMode,
        showCollisionArea: widget.showCollisionArea,
        collisionAreaColor: widget.collisionAreaColor ??
            Colors.lightGreenAccent.setOpacity(0.5),
        lightingColorGame: widget.lightingColorGame,
        cameraConfig: widget.cameraConfig,
        colorFilter: widget.colorFilter,
        onReady: widget.onReady,
        globalForces: widget.globalForces,
      ),
    );
  }
}
