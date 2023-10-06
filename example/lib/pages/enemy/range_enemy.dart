import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/person_sprite_sheet.dart';
import 'package:flutter/material.dart';

class RageEnemy extends SimpleEnemy with BlockMovementCollision {
  late TextPaint _textPaint;
  final String text = 'RangeEnemy';
  RageEnemy({
    required Vector2 position,
  }) : super(
          position: position,
          animation: PersonSpritesheet(path: 'orc.png').simpleAnimation(),
          size: Vector2.all(24),
          speed: 20,
          initDirection: Direction.down,
        );

  @override
  void update(double dt) {
    seeAndMoveToAttackRange(
      positioned: (p) {
        if (checkInterval('attack', 600, dt)) {
          _playAttackAnimation();
        }
      },
    );
    super.update(dt);
  }

  @override
  Future<void> onLoad() {
    /// Adds rectangle collision
    add(RectangleHitbox(size: size / 2, position: size / 4));
    _addsText();

    return super.onLoad();
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

  void _playAttackAnimation() {
    switch (lastDirection) {
      case Direction.left:
        animation?.playOnceOther(PersonAttackEnum.rangeLeft);
        break;
      case Direction.right:
        animation?.playOnceOther(PersonAttackEnum.rangeRight);
        break;
      case Direction.up:
        animation?.playOnceOther(PersonAttackEnum.rangeUp);
        break;
      case Direction.down:
        animation?.playOnceOther(PersonAttackEnum.rangeDown);
        break;
      case Direction.upLeft:
        animation?.playOnceOther(PersonAttackEnum.rangeUpLeft);
        break;
      case Direction.upRight:
        animation?.playOnceOther(PersonAttackEnum.rangeUpRight);
        break;
      case Direction.downLeft:
        animation?.playOnceOther(PersonAttackEnum.rangeDownLeft);
        break;
      case Direction.downRight:
        animation?.playOnceOther(PersonAttackEnum.rangeDownRight);
        break;
    }
  }
}
