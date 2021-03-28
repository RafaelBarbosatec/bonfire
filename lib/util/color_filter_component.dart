import 'dart:ui';

import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/util/game_color_filter.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

class ColorFilterComponent extends Component with HasGameRef<BonfireGame> {
  final GameColorFilter colorFilter;

  ColorFilterComponent(this.colorFilter);
  @override
  void render(Canvas canvas) {
    if (colorFilter?.enable == true) {
      canvas.save();
      canvas.drawColor(
        colorFilter?.color,
        colorFilter?.blendMode,
      );
      canvas.restore();
    }
  }

  @override
  void update(double t) {
    colorFilter.gameRef = gameRef;
  }

  @override
  int priority() => PriorityLayer.LIGHTING + 1;
}
