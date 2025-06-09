import 'package:bonfire/bonfire.dart';
import 'package:flappy_bird/components/pipe/pipe.dart';
import 'package:flappy_bird/components/scenario/base.dart';

class PipeLine extends GameDecoration with Movement {
  static const pipeSpaces = 70.0;
  final Vector2 offset;
  final Function onWin;
  bool alreadyWin = false;
  PipeLine({required this.offset, required this.onWin, double speed = 50})
      : super(
          size: Vector2(Pipe.pipeWidth, (Pipe.pipeHeight * 2) + pipeSpaces),
          position: Vector2.zero(),
        ) {
    this.speed = speed;
    moveLeft();
  }

  @override
  void update(double dt) {
    if (_goOutOnTheLeft() && !isRemoving) {
      removeFromParent();
    }
    if (!alreadyWin && gameRef.player!.left > right) {
      alreadyWin = true;
      onWin();
    }
    super.update(dt);
  }

  bool _goOutOnTheLeft() {
    return position.x < -(size.x);
  }

  @override
  Future<void> onLoad() {
    add(Pipe(position: Vector2.zero(), inverted: true));
    add(Pipe(position: Vector2(0, pipeSpaces + Pipe.pipeHeight)));
    final mapSize = gameRef.map.size;
    position = Vector2(
      mapSize.x + offset.x,
      (mapSize.y - size.y) / 2 + offset.y,
    );
    return super.onLoad();
  }

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    if (other is Pipe || other is ParallaxBaseBackground) {
      return false;
    }
    return super.onComponentTypeCheck(other);
  }

  @override
  int get priority => LayerPriority.BACKGROUND;
}
