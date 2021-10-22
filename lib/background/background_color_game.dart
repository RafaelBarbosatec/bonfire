import 'dart:ui';

import 'package:bonfire/background/game_background.dart';

class BackgroundColorGame extends GameBackground {
  final Color color;
  BackgroundColorGame(this.color);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawColor(
      color,
      BlendMode.src,
    );
  }
}
