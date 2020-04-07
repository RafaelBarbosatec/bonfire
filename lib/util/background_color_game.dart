import 'dart:ui';

import 'package:bonfire/util/game_component.dart';

class BackgroundColorGame extends GameComponent {
  final Color color;
  BackgroundColorGame(this.color);
  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      new Rect.fromLTRB(0.0, 0.0, gameRef.size.width, gameRef.size.height),
      new Paint()..color = color,
    );
  }

  @override
  void update(double t) {}
}
