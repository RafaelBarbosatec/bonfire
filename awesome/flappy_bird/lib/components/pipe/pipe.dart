import 'package:bonfire/bonfire.dart';
import 'package:flappy_bird/util/spritesheet.dart';

class Pipe extends GameDecoration with FlipRender {
  static const pipeHeight = 320.0;
  static const pipeWidth = 52.0;
  final bool inverted;
  Pipe({
    required super.position,
    this.inverted = false,
  }) : super.withSprite(
          size: Vector2(pipeWidth, pipeHeight),
          sprite: Spritesheet.pipe,
        ) {
    flipRenderVertically = inverted;
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: size,
        isSolid: true,
      ),
    );
    return super.onLoad();
  }
}
