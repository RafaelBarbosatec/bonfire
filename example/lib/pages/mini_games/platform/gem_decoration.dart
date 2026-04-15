import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/platform/platform_spritesheet.dart';

class GemDecoration extends GameDecoration with Sensor {
  bool _alreadyContad = false;
  GemDecoration({
    required Vector2 position,
  }) : super.withAnimation(
          animation: PlatformSpritesheet.gem,
          position: position,
          size: Vector2(15, 13),
        );

  @override
  void onContact(GameComponent component) {
    if (component is Player && !_alreadyContad) {
      _alreadyContad = true;
      playSpriteAnimationOnce(
        PlatformSpritesheet.itemFeedback,
        size: Vector2.all(32),
        offset: (Vector2.all(32) / -2) + Vector2(15, 13) / 2,
        onFinish: removeFromParent,
      );
    }
    super.onContact(component);
  }
}
