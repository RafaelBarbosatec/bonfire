import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/color_filter/game_color_filter.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flutter/widgets.dart';

abstract class ColorFilterInterface {
  GameColorFilter config = GameColorFilter();
  void animateTo(
    Color color, {
    BlendMode? blendMode,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
    VoidCallback? onFinish,
  });
}

class ColorFilterComponent extends GameComponent
    implements ColorFilterInterface {
  ColorTween? _tween;

  @override
  GameColorFilter config;

  ColorFilterComponent(this.config);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (config.enable == true) {
      canvas.save();
      canvas.drawColor(
        config.color!,
        config.blendMode,
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
    Color color, {
    BlendMode? blendMode,
    Duration duration = const Duration(milliseconds: 500),
    curve = Curves.decelerate,
    VoidCallback? onFinish,
  }) {
    if (blendMode != null) {
      config.blendMode = blendMode;
    }
    _tween = ColorTween(
      begin: config.color ?? Color(0x00000000),
      end: color,
    );

    gameRef.getValueGenerator(
      duration,
      onChange: (value) {
        config.color = _tween?.transform(value);
      },
      onFinish: () {
        config.color = color;
        onFinish?.call();
      },
      curve: curve,
    ).start();
  }
}
