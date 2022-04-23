import 'package:bonfire/util/mixins/pointer_detector.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Widget used to run the Game
/// This widget also is responsible in capture gesture with `Listener`
class CustomGameWidget<T extends Game> extends StatelessWidget {
  /// instance of the game
  final T game;

  /// A map to show widgets overlay.
  final Map<String, OverlayWidgetBuilder<T>>? overlayBuilderMap;

  /// "Overlay" which must be shown in the game.
  final List<String>? initialActiveOverlays;

  /// The [FocusNode] to control the games focus to receive event inputs.
  /// If omitted, defaults to an internally controlled focus node.
  final FocusNode? focusNode;

  /// Whether the [focusNode] requests focus once the game is mounted.
  /// Defaults to true.
  final bool autofocus;

  /// Initial mouse cursor for this [GameWidget]
  /// mouse cursor can be changed in runtime using [Game.mouseCursor]
  final MouseCursor? mouseCursor;

  const CustomGameWidget({
    Key? key,
    required this.game,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
    this.focusNode,
    this.autofocus = true,
    this.mouseCursor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Listener(
        onPointerDown: game is PointerDetector
            ? (game as PointerDetector).onPointerDown
            : null,
        onPointerMove: game is PointerDetector
            ? (game as PointerDetector).onPointerMove
            : null,
        onPointerUp: game is PointerDetector
            ? (game as PointerDetector).onPointerUp
            : null,
        onPointerCancel: game is PointerDetector
            ? (game as PointerDetector).onPointerCancel
            : null,
        onPointerHover: game is PointerDetector
            ? (game as PointerDetector).onPointerHover
            : null,
        onPointerSignal: game is PointerDetector
            ? (game as PointerDetector).onPointerSignal
            : null,
        child: GameWidget(
          game: game,
          overlayBuilderMap: overlayBuilderMap,
          initialActiveOverlays: initialActiveOverlays,
          focusNode: focusNode,
          autofocus: autofocus,
          mouseCursor: mouseCursor,
        ),
      ),
    );
  }
}
