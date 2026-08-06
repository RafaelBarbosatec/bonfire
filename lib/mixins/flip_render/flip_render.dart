import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/mixins/flip_render/flip_render_api.dart';

export 'flip_render_api.dart';

/// Mixin that flips the component render horizontally or vertically.
///
/// Access all flip functionality through the [flipRender] API.
mixin WithFlipRender on GameComponent {
  late final FlipRenderApi flipRender = FlipRenderApi(this);

  @override
  void render(Canvas canvas) {
    if (flipRender.isFlipped) {
      final center = size / 2;
      canvas.save();
      canvas.translate(center.x, center.y);
      canvas.scale(
        flipRender.horizontally ? -1 : 1,
        flipRender.vertically ? -1 : 1,
      );
      canvas.translate(-center.x, -center.y);
    }
    super.render(canvas);
    if (flipRender.isFlipped) {
      canvas.restore();
    }
  }
}
