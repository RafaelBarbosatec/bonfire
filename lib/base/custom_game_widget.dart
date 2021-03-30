import 'package:bonfire/util/mixins/pointer_detector.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class CustomGameWidget<T extends Game> extends StatelessWidget {
  final T game;

  const CustomGameWidget({Key key, this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Listener(
        onPointerDown: game is PointerDetector
            ? (PointerDownEvent d) => (game as PointerDetector).onPointerDown(d)
            : null,
        onPointerMove: game is PointerDetector
            ? (PointerMoveEvent d) => (game as PointerDetector).onPointerMove(d)
            : null,
        onPointerUp: game is PointerDetector
            ? (PointerUpEvent d) => (game as PointerDetector).onPointerUp(d)
            : null,
        onPointerCancel: game is PointerDetector
            ? (PointerCancelEvent d) =>
                (game as PointerDetector).onPointerCancel(d)
            : null,
        child: GameWidget(
          game: game,
        ),
      ),
    );
  }
}
