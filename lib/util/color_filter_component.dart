import 'dart:ui';

import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/util/game_color_filter.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';

class ColorFilterComponent extends Component with HasGameRef<BonfireGame> {
  final GameColorFilter colorFilter;

  ColorFilterComponent(this.colorFilter);
  @override
  void render(Canvas canvas) {
    if (colorFilter.enable == true) {
      canvas.save();
      canvas.drawColor(
        colorFilter.color!,
        colorFilter.blendMode!,
      );
      canvas.restore();
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    colorFilter.gameRef = gameRef;
    super.onGameResize(gameSize);
  }

  @override
  int get priority {
    return LayerPriority.getColorFilterPriority(gameRef.highestPriority);
  }
}
