import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/person_sprite_sheet.dart';
import 'package:flutter/material.dart';

class MeleeEnemy extends SimpleEnemy with UseBehavior {
  late TextPaint _textPaint;
  final String text = 'MeleeEnemy';
  final IntervalTick _attackTick = IntervalTick(
    600,
    tickFirstUpdate: true,
  );
  MeleeEnemy({required Vector2 position})
      : super(
          position: position,
          animation: PersonSpritesheet(path: 'orc2.png').simpleAnimation(),
          size: Vector2.all(24),
          speed: 25,
          initDirection: Direction.down,
        );

  /// Declarative AI: moves to the player when seen and attacks when close.
  /// When the player is not observed, hides the stroke and stops moving.
  @override
  late final List<Behavior> behaviors = [
    BSeeAndMoveToTarget(
      target: gameRef.player!,
      radiusVision: 32,
      onClose: (dt, _) {
        animation?.showStroke(Colors.white, 1);
        if (_attackTick.update(dt)) {
          _playAttackAnimation();
        }
      },
      doElseBehavior: BCustom(
        behavior: (dt, comp, game) {
          animation?.hideStroke();
          if (comp is Movement) {
            comp.stop();
          }
          return true;
        },
      ),
    ),
  ];

  @override
  Future<void> onLoad() {
    /// Adds rectangle collision
    add(RectangleHitbox(size: size / 2, position: size / 4));
    _addsText();
    return super.onLoad();
  }

  void _playAttackAnimation() {
    switch (direction) {
      case Direction.left:
        animation?.playOnceOther(PersonAttackEnum.meeleLeft);
        break;
      case Direction.right:
        animation?.playOnceOther(PersonAttackEnum.meeleRight);
        break;
      case Direction.up:
        animation?.playOnceOther(PersonAttackEnum.meeleUp);
        break;
      case Direction.down:
        animation?.playOnceOther(PersonAttackEnum.meeleDown);
        break;
      case Direction.upLeft:
        animation?.playOnceOther(PersonAttackEnum.meeleUpLeft);
        break;
      case Direction.upRight:
        animation?.playOnceOther(PersonAttackEnum.meeleUpRight);
        break;
      case Direction.downLeft:
        animation?.playOnceOther(PersonAttackEnum.meeleDownLeft);
        break;
      case Direction.downRight:
        animation?.playOnceOther(PersonAttackEnum.meeleDownRight);
        break;
    }
  }

  void _addsText() {
    _textPaint = TextPaint(
      style: TextStyle(
        fontSize: size.x / 5,
        color: Colors.white,
      ),
    );
    var textSize = _textPaint.getLineMetrics(text).size;
    add(
      TextComponent(
        text: text,
        position: Vector2((textSize.x / -2) + size.x / 2, -2),
        textRenderer: _textPaint,
      ),
    );
  }
}
