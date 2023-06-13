import 'dart:async';

import 'package:bonfire/bonfire.dart';

class PlatformJumpAnimations {
  final FutureOr<SpriteAnimation> jumpUpRight;
  final FutureOr<SpriteAnimation>? jumpUpLeft;
  final FutureOr<SpriteAnimation> jumpDownRight;
  final FutureOr<SpriteAnimation>? jumpDownLeft;

  PlatformJumpAnimations({
    required this.jumpUpRight,
    required this.jumpDownRight,
    this.jumpUpLeft,
    this.jumpDownLeft,
  });
}

class PlatformAnimations {
  final FutureOr<SpriteAnimation> idleRight;
  final FutureOr<SpriteAnimation> runRight;
  final FutureOr<SpriteAnimation>? idleLeft;
  final FutureOr<SpriteAnimation>? runLeft;
  final PlatformJumpAnimations? jump;
  final Map<String, FutureOr<SpriteAnimation>>? others;

  PlatformAnimations({
    required this.idleRight,
    required this.runRight,
    this.idleLeft,
    this.runLeft,
    this.jump,
    this.others,
  });
}
