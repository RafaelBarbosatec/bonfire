import 'dart:async';

import 'package:bonfire/background/game_background.dart';
import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/base/custom_game_widget.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/camera/camera_config.dart';
import 'package:bonfire/color_filter/game_color_filter.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/game_interface/game_interface.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/npc/enemy/enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/game_controller.dart';
import 'package:bonfire/util/mixins/pointer_detector.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BonfireWidget extends StatefulWidget {
  /// The player-controlling component.
  final JoystickController? joystick;

  /// Represents the character controlled by the user in the game. Instances of this class has actions and movements ready to be used and configured.
  final FutureOr<Player?> player;

  /// The way you cand raw things like life bars, stamina and settings. In another words, anything that you may add to the interface to the game.
  final GameInterface? interface;

  /// Represents a map (or world) where the game occurs.
  final FutureOr<MapGame> map;

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

  final TapInGame? onTapDown;
  final TapInGame? onTapUp;

  final ValueChanged<BonfireGame>? onReady;
  final Map<String, OverlayWidgetBuilder<BonfireGame>>? overlayBuilderMap;
  final List<String>? initialActiveOverlays;
  final List<Enemy>? enemies;
  final List<GameDecoration>? decorations;
  final FutureOr<List<GameComponent>?> components;
  final GameBackground? background;
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
    this.onTapDown,
    this.onTapUp,
    this.onReady,
    this.focusNode,
    this.autofocus = true,
    this.mouseCursor,
    this.progress,
    this.progressTransitionDuration = const Duration(milliseconds: 500),
    this.progressTransitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
  }) : super(key: key);

  @override
  _BonfireWidgetState createState() => _BonfireWidgetState();
}

class _BonfireWidgetState extends State<BonfireWidget> {
  BonfireGame? _game;
  late StreamController<bool> _loadingStream;

  @override
  void dispose() {
    _loadingStream.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(BonfireWidget oldWidget) {
    if (widget.constructionMode) {
      _refreshGame();
    }
    super.didUpdateWidget(oldWidget);
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
      children: [
        if (_game != null)
          CustomGameWidget(
            game: _game!,
            overlayBuilderMap: widget.overlayBuilderMap,
            initialActiveOverlays: widget.initialActiveOverlays,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            mouseCursor: widget.mouseCursor,
          ),
        StreamBuilder<bool>(
          stream: _loadingStream.stream,
          builder: (context, snapshot) {
            bool _loading = !snapshot.hasData || snapshot.data == true;
            return AnimatedSwitcher(
              duration: widget.progressTransitionDuration,
              transitionBuilder: widget.progressTransitionBuilder,
              child: _loading ? _defaultProgress() : SizedBox.shrink(),
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
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
  }

  void _refreshGame() async {
    final map = await widget.map;
    await _game?.map.updateTiles(map.tiles);

    _game?.decorations().forEach((d) => d.removeFromParent());
    widget.decorations?.forEach((d) => _game!.add(d));

    _game?.enemies().forEach((e) => e.removeFromParent());
    widget.enemies?.forEach((e) => _game!.add(e));
  }

  void _buildGame() async {
    final map = await widget.map;
    final components = await widget.components;
    final player = await widget.player;
    await Future.delayed(Duration.zero);
    setState(() {
      _game = BonfireGame(
        context: context,
        joystickController: widget.joystick,
        player: player,
        interface: widget.interface,
        map: map,
        decorations: widget.decorations,
        enemies: widget.enemies,
        components: components ?? [],
        background: widget.background,
        constructionMode: widget.constructionMode,
        showCollisionArea: widget.showCollisionArea,
        showFPS: widget.showFPS,
        gameController: widget.gameController,
        constructionModeColor:
            widget.constructionModeColor ?? Colors.cyan.withOpacity(0.5),
        collisionAreaColor: widget.collisionAreaColor ??
            Colors.lightGreenAccent.withOpacity(0.5),
        lightingColorGame: widget.lightingColorGame,
        cameraConfig: widget.cameraConfig,
        colorFilter: widget.colorFilter,
        onReady: (game) {
          widget.onReady?.call(game);
          _showProgress(false);
        },
        onTapDown: widget.onTapDown,
        onTapUp: widget.onTapUp,
      );
    });
  }

  void _showProgress(bool show) async {
    await Future.delayed(Duration.zero);
    _loadingStream.add(show);
  }
}
