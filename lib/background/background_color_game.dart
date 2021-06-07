import 'dart:ui';

import 'package:bonfire/background/game_background.dart';

class BackgroundColorGame extends GameBackground {
  final Color color;
  BackgroundColorGame(this.color);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      new Rect.fromLTRB(0.0, 0.0, gameRef.size.x, gameRef.size.y),
      new Paint()..color = color,
    );
  }
}
