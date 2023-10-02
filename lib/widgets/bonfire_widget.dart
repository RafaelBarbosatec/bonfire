import 'dart:async';

import 'package:bonfire/background/game_background.dart';
import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/base/listener_game_widget.dart';
import 'package:bonfire/camera/camera_config.dart';
import 'package:bonfire/color_filter/game_color_filter.dart';
import 'package:bonfire/forces/forces_2d.dart';
import 'package:bonfire/game_interface/game_interface.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/map/base/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:flutter/material.dart';

class BonfireWidget extends StatefulWidget {
  /// The player-controlling component.
  final JoystickController? joystick;

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

  final Widget? progress;
  final Duration progressTransitionDuration;
  final AnimatedSwitcherTransitionBuilder progressTransitionBuilder;

  final ValueChanged<BonfireGameInterface>? onReady;
  final Map<String, OverlayWidgetBuilder<BonfireGame>>? overlayBuilderMap;
  final List<String>? initialActiveOverlays;
  final List<GameComponent>? components;
  final GameBackground? background;
  final CameraConfig? cameraConfig;
  final GameColorFilter? colorFilter;
  final VoidCallback? onDispose;
  final Duration delayToHideProgress;
  final List<Force2D>? globalForces;

  const BonfireWidget({
    Key? key,
    required this.map,
    this.joystick,
    this.player,
    this.interface,
    this.background,
    this.debugMode = false,
    this.showCollisionArea = false,
    this.collisionAreaColor,
    this.lightingColorGame,
    this.backgroundColor,
    this.colorFilter,
    this.components,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
    this.cameraConfig,
    this.onReady,
    this.focusNode,
    this.autofocus = true,
    this.mouseCursor,
    this.progress,
    this.delayToHideProgress = const Duration(milliseconds: 500),
    this.progressTransitionDuration = const Duration(milliseconds: 500),
    this.progressTransitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.onDispose,
    this.globalForces,
  }) : super(key: key);

  @override
  BonfireWidgetState createState() => BonfireWidgetState();
}

class BonfireWidgetState extends State<BonfireWidget> {
  late BonfireGame _game;
  late StreamController<bool> _loadingStream;

  @override
  void dispose() {
    _loadingStream.close();
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  void initState() {
    _loadingStream = StreamController<bool>();
    _buildGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ListenerGameWidget(
          game: _game,
          overlayBuilderMap: widget.overlayBuilderMap,
          initialActiveOverlays: widget.initialActiveOverlays,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          mouseCursor: widget.mouseCursor,
        ),
        StreamBuilder<bool>(
          stream: _loadingStream.stream,
          builder: (context, snapshot) {
            bool loading = !snapshot.hasData || snapshot.data == true;
            return AnimatedSwitcher(
              duration: widget.progressTransitionDuration,
              transitionBuilder: widget.progressTransitionBuilder,
              child: loading ? _defaultProgress() : Container(),
            );
          },
        ),
      ],
    );
  }

  Widget _defaultProgress() {
    return widget.progress ??
        Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
  }

  void _buildGame() {
    _game = BonfireGame(
      context: context,
      joystickController: widget.joystick,
      player: widget.player,
      interface: widget.interface,
      map: widget.map,
      components: widget.components ?? [],
      background: widget.background,
      backgroundColor: widget.backgroundColor,
      debugMode: widget.debugMode,
      showCollisionArea: widget.showCollisionArea,
      collisionAreaColor:
          widget.collisionAreaColor ?? Colors.lightGreenAccent.withOpacity(0.5),
      lightingColorGame: widget.lightingColorGame,
      cameraConfig: widget.cameraConfig,
      colorFilter: widget.colorFilter,
      onReady: (game) {
        widget.onReady?.call(game);
        _hideProgress();
      },
      globalForces: widget.globalForces,
    );
  }

  void _hideProgress() async {
    await Future.delayed(widget.delayToHideProgress);
    _loadingStream.add(false);
  }
}
