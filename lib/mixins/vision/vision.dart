import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/mixins/vision/vision_api.dart';
import 'package:flutter/material.dart';

export 'vision_api.dart';

/// Mixin that adds vision/line-of-sight detection to a component.
///
/// Access all vision functionality through the [vision] API object.
mixin WithVision on GameComponent {
  late final VisionApi vision = VisionApi(this);

  @override
  void onRemove() {
    vision.cleanCache();
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    vision.render(canvas);
  }
}
