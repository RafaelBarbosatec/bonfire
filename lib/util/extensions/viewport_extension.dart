import 'package:bonfire/bonfire.dart';
import 'package:flame/camera.dart';

extension ViewportExt on Viewport {
  double get scale {
    if (this is FixedResolutionViewport) {
      return (this as FixedResolutionViewport).scale.maxValue();
    } else if (this is FixedAspectRatioViewport) {
      return (this as FixedAspectRatioViewport).scale;
    }
    return 1.0;
  }
}
