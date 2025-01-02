import 'dart:ui';

import 'package:bonfire/bonfire.dart';

class RenderTransformWrapper {
  final List<RenderTransformer> transforms;
  final void Function(Canvas canvas, Paint paint) render;

  RenderTransformWrapper({required this.transforms, required this.render});

  void execRender(Canvas canvas, Paint paint) {
    var index = 0;
    for (final transform in transforms) {
      if (transform.transform(canvas)) {
        index++;
      }
    }
    render(canvas, paint);
    for (var i = 0; i < index; i++) {
      canvas.restore();
    }
  }
}

abstract class RenderTransformer {
  bool transform(Canvas canvas);
}

class CenterAdjustRenderTransform extends RenderTransformer {
  final CenterAdjustRenderData? Function() onTransform;

  CenterAdjustRenderTransform(this.onTransform);

  @override
  bool transform(Canvas canvas) {
    final data = onTransform();
    if (data == null) {
      return false;
    }
    canvas.save();
    final diff = data.center - data.newCenter;
    canvas.translate(diff.x, diff.y);
    return true;
  }
}

class CenterAdjustRenderData {
  final Vector2 center;
  final Vector2 newCenter;

  CenterAdjustRenderData({
    required this.center,
    required this.newCenter,
  });
}

class FlipRenderTransform extends RenderTransformer {
  final FlipRenderTransformData? Function() onTransform;

  FlipRenderTransform(this.onTransform);

  @override
  bool transform(Canvas canvas) {
    final data = onTransform();
    if (data == null) {
      return false;
    }
    canvas.save();
    canvas.translate(data.center.x, data.center.y);
    canvas.scale(
      data.horizontal ? -1 : 1,
      data.vertical ? -1 : 1,
    );
    canvas.translate(-data.center.x, -data.center.y);
    return true;
  }
}

class FlipRenderTransformData {
  final Vector2 center;
  final bool horizontal;
  final bool vertical;

  FlipRenderTransformData({
    required this.center,
    required this.horizontal,
    required this.vertical,
  });
}
