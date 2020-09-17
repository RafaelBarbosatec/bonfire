import 'package:bonfire/base/rpg_game.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

class GameColorFilter with HasGameRef<RPGGame> {
  Color color;
  BlendMode blendMode;
  ColorTween _tween;

  GameColorFilter({this.color, this.blendMode});

  bool get enable => color != null && blendMode != null;

  void animateToColor(
    Color color, {
    BlendMode blendMode,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    this.blendMode = blendMode ?? this.blendMode;
    _tween = ColorTween(begin: this.color, end: color);

    gameRef.getValueGenerator(
      duration ?? Duration(seconds: 1),
      onChange: (value) {
        this.color = _tween.transform(value);
      },
      onFinish: () {
        this.color = color;
      },
    ).start();
  }
}
