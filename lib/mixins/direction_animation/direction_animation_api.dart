import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';

typedef DirectionAnimationExecutionListener = bool Function(
  DirectionAnimationMethod method,
);

enum DirectionAnimationMethod {
  onPlayRunDownAnimation,
  onPlayRunUpAnimation,
  onPlayRunUpLeftAnimation,
  onPlayRunUpRightAnimation,
  onPlayRunDownLeftAnimation,
  onPlayRunDownRightAnimation,
  onPlayRunLeftAnimation,
  onPlayRunRightAnimation,
  onPlayIdleUpAnimation,
  onPlayIdleDownAnimation,
  onPlayIdleUpLeftAnimation,
  onPlayIdleUpRightAnimation,
  onPlayIdleDownLeftAnimation,
  onPlayIdleDownRightAnimation,
  onPlayIdleLeftAnimation,
  onPlayIdleRightAnimation,
}

/// API for managing movement direction animations.
class DirectionAnimationApi {
  final Movement comp;

  SimpleDirectionAnimation? animation;

  final List<DirectionAnimationExecutionListener> _executionListeners = [];

  DirectionAnimationApi(this.comp);

  Vector2 get animationScale =>
      comp.size.clone()..divide(animation!.animationSize);

  void render(Canvas canvas, Paint paint) {
    if (!comp.isRemoving && comp.isVisible) {
      animation?.render(canvas, paint);
    }
  }

  void update(double dt) {
    animation?.update(dt, comp.size);
  }

  void updateAnimation() {
    if (!comp.isMoving) {
      return;
    }

    switch (comp.direction) {
      case Direction.left:
        onPlayRunLeftAnimation();
        break;
      case Direction.right:
        onPlayRunRightAnimation();
        break;
      case Direction.up:
        onPlayRunUpAnimation();
        break;
      case Direction.down:
        onPlayRunDownAnimation();
        break;
      case Direction.upLeft:
        onPlayRunUpLeftAnimation();
        break;
      case Direction.upRight:
        onPlayRunUpRightAnimation();
        break;
      case Direction.downLeft:
        onPlayRunDownLeftAnimation();
        break;
      case Direction.downRight:
        onPlayRunDownRightAnimation();
        break;
    }
  }

  void playIdleAnimation() {
    switch (comp.direction) {
      case Direction.left:
        onPlayIdleLeftAnimation();
        break;
      case Direction.right:
        onPlayIdleRightAnimation();
        break;
      case Direction.up:
        onPlayIdleUpAnimation();
        break;
      case Direction.down:
        onPlayIdleDownAnimation();
        break;
      case Direction.upLeft:
        onPlayIdleUpLeftAnimation();
        break;
      case Direction.upRight:
        onPlayIdleUpRightAnimation();
        break;
      case Direction.downLeft:
        onPlayIdleDownLeftAnimation();
        break;
      case Direction.downRight:
        onPlayIdleDownRightAnimation();
        break;
    }
  }

  Future<void> onLoad(BonfireGameInterface gameRef) async {
    await animation?.onLoad(gameRef);
  }

  Future<void> replaceAnimation(
    SimpleDirectionAnimation newAnimation, {
    bool doIdle = false,
    VoidCallback? idleCallback,
  }) async {
    await newAnimation.onLoad(comp.gameRef);
    animation = newAnimation;
    if (doIdle) {
      idleCallback?.call();
    }
  }

  void onAnimationExecutionListener(
    DirectionAnimationExecutionListener callback,
  ) {
    _executionListeners.add(callback);
  }

  void removeAnimationExecutionListener(
    DirectionAnimationExecutionListener callback,
  ) {
    _executionListeners.remove(callback);
  }

  void clearAnimationExecutionListeners() {
    _executionListeners.clear();
  }

  bool canExecuteAnimation(DirectionAnimationMethod method) {
    for (final callback in _executionListeners) {
      if (!callback(method)) {
        return false;
      }
    }
    return true;
  }

  void play(SimpleAnimationEnum animationType) {
    animation?.play(animationType);
  }

  void onPlayRunDownAnimation() {
    if (!canExecuteAnimation(DirectionAnimationMethod.onPlayRunDownAnimation)) {
      return;
    }
    if (animation?.canRunDown == true) {
      play(SimpleAnimationEnum.runDown);
    } else {
      if (comp.hDirection.isLeftSide) {
        play(SimpleAnimationEnum.runLeft);
      } else {
        play(SimpleAnimationEnum.runRight);
      }
    }
  }

  void onPlayRunUpAnimation() {
    if (!canExecuteAnimation(DirectionAnimationMethod.onPlayRunUpAnimation)) {
      return;
    }
    if (animation?.canRunUp == true) {
      play(SimpleAnimationEnum.runUp);
    } else {
      if (comp.hDirection.isLeftSide) {
        play(SimpleAnimationEnum.runLeft);
      } else {
        play(SimpleAnimationEnum.runRight);
      }
    }
  }

  void onPlayRunUpLeftAnimation() {
    if (!canExecuteAnimation(
      DirectionAnimationMethod.onPlayRunUpLeftAnimation,
    )) {
      return;
    }
    if (animation?.canRunUpLeft == true) {
      play(SimpleAnimationEnum.runUpLeft);
    } else {
      play(SimpleAnimationEnum.runLeft);
    }
  }

  void onPlayRunUpRightAnimation() {
    if (!canExecuteAnimation(
      DirectionAnimationMethod.onPlayRunUpRightAnimation,
    )) {
      return;
    }
    if (animation?.canRunUpRight == true) {
      play(SimpleAnimationEnum.runUpRight);
    } else {
      play(SimpleAnimationEnum.runRight);
    }
  }

  void onPlayRunDownLeftAnimation() {
    if (!canExecuteAnimation(
      DirectionAnimationMethod.onPlayRunDownLeftAnimation,
    )) {
      return;
    }
    if (animation?.canRunDownLeft == true) {
      play(SimpleAnimationEnum.runDownLeft);
    } else {
      play(SimpleAnimationEnum.runLeft);
    }
  }

  void onPlayRunDownRightAnimation() {
    if (!canExecuteAnimation(
      DirectionAnimationMethod.onPlayRunDownRightAnimation,
    )) {
      return;
    }
    if (animation?.canRunDownRight == true) {
      play(SimpleAnimationEnum.runDownRight);
    } else {
      play(SimpleAnimationEnum.runRight);
    }
  }

  void onPlayRunLeftAnimation() {
    if (!canExecuteAnimation(DirectionAnimationMethod.onPlayRunLeftAnimation)) {
      return;
    }
    play(SimpleAnimationEnum.runLeft);
  }

  void onPlayRunRightAnimation() {
    if (!canExecuteAnimation(
      DirectionAnimationMethod.onPlayRunRightAnimation,
    )) {
      return;
    }
    play(SimpleAnimationEnum.runRight);
  }

  void onPlayIdleUpAnimation() {
    if (!canExecuteAnimation(DirectionAnimationMethod.onPlayIdleUpAnimation)) {
      return;
    }
    if (animation?.canIdleUp == true) {
      play(SimpleAnimationEnum.idleUp);
    } else {
      if (comp.hDirection.isLeftSide) {
        play(SimpleAnimationEnum.idleLeft);
      } else {
        play(SimpleAnimationEnum.idleRight);
      }
    }
  }

  void onPlayIdleDownAnimation() {
    if (!canExecuteAnimation(
      DirectionAnimationMethod.onPlayIdleDownAnimation,
    )) {
      return;
    }
    if (animation?.canIdleDown == true) {
      play(SimpleAnimationEnum.idleDown);
    } else {
      if (comp.hDirection.isLeftSide) {
        play(SimpleAnimationEnum.idleLeft);
      } else {
        play(SimpleAnimationEnum.idleRight);
      }
    }
  }

  void onPlayIdleUpLeftAnimation() {
    if (!canExecuteAnimation(
      DirectionAnimationMethod.onPlayIdleUpLeftAnimation,
    )) {
      return;
    }
    play(SimpleAnimationEnum.idleUpLeft);
  }

  void onPlayIdleUpRightAnimation() {
    if (!canExecuteAnimation(
      DirectionAnimationMethod.onPlayIdleUpRightAnimation,
    )) {
      return;
    }
    play(SimpleAnimationEnum.idleUpRight);
  }

  void onPlayIdleDownLeftAnimation() {
    if (!canExecuteAnimation(
      DirectionAnimationMethod.onPlayIdleDownLeftAnimation,
    )) {
      return;
    }
    play(SimpleAnimationEnum.idleDownLeft);
  }

  void onPlayIdleDownRightAnimation() {
    if (!canExecuteAnimation(
      DirectionAnimationMethod.onPlayIdleDownRightAnimation,
    )) {
      return;
    }
    play(SimpleAnimationEnum.idleDownRight);
  }

  void onPlayIdleLeftAnimation() {
    if (!canExecuteAnimation(
      DirectionAnimationMethod.onPlayIdleLeftAnimation,
    )) {
      return;
    }
    play(SimpleAnimationEnum.idleLeft);
  }

  void onPlayIdleRightAnimation() {
    if (!canExecuteAnimation(
      DirectionAnimationMethod.onPlayIdleRightAnimation,
    )) {
      return;
    }
    play(SimpleAnimationEnum.idleRight);
  }
}
