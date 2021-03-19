import 'package:bonfire/bonfire.dart';
import 'package:example/decoration/potion_life.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/material.dart';

class Chest extends GameDecoration with TapGesture {
  final Position initPosition;
  bool _observedPlayer = false;

  TextConfig _textConfig;
  Chest(this.initPosition)
      : super.animation(
          FlameAnimation.Animation.sequenced(
            "itens/chest_spritesheet.png",
            8,
            textureWidth: 16,
            textureHeight: 16,
          ),
          width: DungeonMap.tileSize * 0.6,
          height: DungeonMap.tileSize * 0.6,
          position: initPosition,
        ) {
    _textConfig = TextConfig(
      color: Colors.white,
      fontSize: width / 2,
    );
  }

  @override
  void update(double dt) {
    this.seePlayer(
      observed: (player) {
        if (!_observedPlayer) {
          _observedPlayer = true;
          _showEmote();
        }
      },
      notObserved: () {
        _observedPlayer = false;
      },
      visionCells: 1,
    );
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_observedPlayer) {
      _textConfig.render(
        canvas,
        'Touch me !!',
        Position(
            position.left - width / 1.5, position.center.dy - (height + 5)),
      );
    }
  }

  @override
  void onTap() {
    if (_observedPlayer) {
      _addPotions();
      remove();
    }
  }

  void _addPotions() {
    gameRef.addGameComponent(
      PotionLife(
        Position(
          position.translate(width * 2, 0).left,
          position.top - height * 2,
        ),
        30,
      ),
    );

    gameRef.addGameComponent(
      PotionLife(
        Position(
          position.translate(width * 2, 0).left,
          position.top + height * 2,
        ),
        30,
      ),
    );

    gameRef.add(
      AnimatedObjectOnce(
        animation: FlameAnimation.Animation.sequenced(
          "smoke_explosin.png",
          6,
          textureWidth: 16,
          textureHeight: 16,
        ),
        position: position.translate(width * 2, 0),
      ),
    );

    gameRef.add(
      AnimatedObjectOnce(
        animation: FlameAnimation.Animation.sequenced(
          "smoke_explosin.png",
          6,
          textureWidth: 16,
          textureHeight: 16,
        ),
        position: position.translate(width * 2, height * 2),
      ),
    );
  }

  void _showEmote() {
    gameRef.add(
      AnimatedFollowerObject(
        animation: FlameAnimation.Animation.sequenced(
          'player/emote_exclamacao.png',
          8,
          textureWidth: 32,
          textureHeight: 32,
        ),
        target: this,
        positionFromTarget: Rect.fromLTWH(18, -6, 16, 16),
      ),
    );
  }
}
