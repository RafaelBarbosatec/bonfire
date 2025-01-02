import 'package:bonfire/bonfire.dart';
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
    return LayerPriority.getHudColorFilterPriority();
  }

  @override
  void animateTo(
    Color color, {
    BlendMode? blendMode,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
    VoidCallback? onFinish,
  }) {
    if (blendMode != null) {
      config.blendMode = blendMode;
    }
    _tween = ColorTween(
      begin: config.color ?? const Color(0x00000000),
      end: color,
    );

    generateValues(
      duration,
      onChange: (value) {
        config.color = _tween?.transform(value);
      },
      onFinish: () {
        config.color = color;
        onFinish?.call();
      },
      curve: curve,
    );
  }
}
