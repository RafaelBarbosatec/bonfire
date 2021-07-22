import 'dart:ui';

import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/util/game_color_filter.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';

import 'bonfire_game_ref.dart';

class ColorFilterComponent extends Component
    with BonfireHasGameRef<BonfireGame> {
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
  set gameRef(BonfireGame gameRef) {
    colorFilter.gameRef = gameRef;
    super.gameRef = gameRef;
  }

  @override
  int get priority {
    return LayerPriority.getColorFilterPriority(gameRef.highestPriority);
  }
}
