// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  PlatformJumpAnimations copyWith({
    FutureOr<SpriteAnimation>? jumpUpRight,
    FutureOr<SpriteAnimation>? jumpUpLeft,
    FutureOr<SpriteAnimation>? jumpDownRight,
    FutureOr<SpriteAnimation>? jumpDownLeft,
  }) {
    return PlatformJumpAnimations(
      jumpUpRight: jumpUpRight ?? this.jumpUpRight,
      jumpUpLeft: jumpUpLeft ?? this.jumpUpLeft,
      jumpDownRight: jumpDownRight ?? this.jumpDownRight,
      jumpDownLeft: jumpDownLeft ?? this.jumpDownLeft,
    );
  }
}

class PlatformAnimations {
  final FutureOr<SpriteAnimation> idleRight;
  final FutureOr<SpriteAnimation> runRight;
  final FutureOr<SpriteAnimation>? idleLeft;
  final FutureOr<SpriteAnimation>? runLeft;
  final PlatformJumpAnimations? jump;
  final Map<String, FutureOr<SpriteAnimation>>? others;
  final Vector2? centerAnchor;

  PlatformAnimations({
    required this.idleRight,
    required this.runRight,
    this.idleLeft,
    this.runLeft,
    this.jump,
    this.others,
    this.centerAnchor,
  });

  PlatformAnimations copyWith({
    FutureOr<SpriteAnimation>? idleRight,
    FutureOr<SpriteAnimation>? runRight,
    FutureOr<SpriteAnimation>? idleLeft,
    FutureOr<SpriteAnimation>? runLeft,
    PlatformJumpAnimations? jump,
    Map<String, FutureOr<SpriteAnimation>>? others,
    Vector2? centerAnchor,
  }) {
    return PlatformAnimations(
      idleRight: idleRight ?? this.idleRight,
      runRight: runRight ?? this.runRight,
      idleLeft: idleLeft ?? this.idleLeft,
      runLeft: runLeft ?? this.runLeft,
      jump: jump ?? this.jump,
      others: others ?? this.others,
      centerAnchor: centerAnchor ?? this.centerAnchor,
    );
  }

  SimpleDirectionAnimation toSimpleDirectionAnimation() {
    return SimpleDirectionAnimation(
      idleRight: idleRight,
      runRight: runRight,
      idleLeft: idleLeft,
      runLeft: runLeft,
      others: {
        if (jump?.jumpUpRight != null)
          JumpAnimationsEnum.jumpUpRight: jump!.jumpUpRight,
        if (jump?.jumpUpLeft != null)
          JumpAnimationsEnum.jumpUpLeft: jump!.jumpUpLeft!,
        if (jump?.jumpDownRight != null)
          JumpAnimationsEnum.jumpDownRight: jump!.jumpDownRight,
        if (jump?.jumpDownLeft != null)
          JumpAnimationsEnum.jumpDownLeft: jump!.jumpDownLeft!,
        ...others ?? {},
      },
      centerAnchor: centerAnchor,
    );
  }
}
