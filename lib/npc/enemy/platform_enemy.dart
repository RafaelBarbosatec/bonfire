import 'package:bonfire/bonfire.dart';

class PlatformEnemy extends SimpleEnemy
    with WithCollision, WithJumper, JumperAnimation {
  final int countJumps;

  PlatformEnemy({
    required super.position,
    required super.size,
    PlatformAnimations? animation,
    super.initDirection,
    super.speed,
    super.life,
    this.countJumps = 1,
  }) : super(
          animation: animation?.toSimpleDirectionAnimation(),
        );

  @override
  void onMount() {
    super.onMount();
    jumper.setMaxJump(countJumps);
  }
}
