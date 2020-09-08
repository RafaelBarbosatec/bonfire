import 'package:bonfire/util/mixins/pointer_detector_mixin.dart';
import 'package:flame/game.dart';
import 'package:flame/game/embedded_game_widget.dart';
import 'package:flutter/widgets.dart';

class CustomWidgetBuilder {
  Widget build(Game game) {
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
        child: Container(
          color: game.backgroundColor(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: EmbeddedGameWidget(game),
          ),
        ),
      ),
    );
  }
}
