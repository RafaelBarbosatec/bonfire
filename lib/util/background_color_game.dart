import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/priority_layer.dart';

class BackgroundColorGame extends GameComponent {
  final Color color;
  BackgroundColorGame(this.color);

  @override
  bool get isHud => true;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      new Rect.fromLTRB(0.0, 0.0, gameRef.size.x, gameRef.size.y),
      new Paint()..color = color,
    );
  }

  @override
  void update(double t) {}

  @override
  int get priority => LayerPriority.BACKGROUND;
}
