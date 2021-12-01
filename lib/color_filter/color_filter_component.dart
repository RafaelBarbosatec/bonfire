import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/color_filter/game_color_filter.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flutter/widgets.dart';

abstract class ColorFilterInterface {
  void animateTo(
    Color color,
    BlendMode blendMode, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  });
}

class ColorFilterComponent extends GameComponent
    implements ColorFilterInterface {
  final GameColorFilter colorFilter;
  ColorTween? _tween;

  ColorFilterComponent(this.colorFilter);
  @override
  void render(Canvas canvas) {
    super.render(canvas);
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
  int get priority {
    return LayerPriority.getColorFilterPriority(gameRef.highestPriority);
  }

  @override
  void animateTo(
    Color color,
    BlendMode blendMode, {
    Duration duration = const Duration(milliseconds: 500),
    curve = Curves.decelerate,
  }) {
    colorFilter.blendMode = blendMode;
    _tween = ColorTween(
      begin: colorFilter.color ?? Color(0x00000000),
      end: color,
    );

    gameRef.getValueGenerator(
      duration,
      onChange: (value) {
        colorFilter.color = _tween?.transform(value);
      },
      onFinish: () {
        colorFilter.color = color;
      },
      curve: curve,
    ).start();
  }
}
