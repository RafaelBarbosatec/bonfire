import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 01/12/21
class TextGameComponent extends GameComponent {
  TextPaint? _textPaint;
  final String text;
  TextGameComponent({
    required this.text,
    required Vector2 position,
    TextStyle? style,
  }) {
    this.position = this.position.copyWith(
          position: position,
        );
    _textPaint = TextPaint(
      style: style,
    );
  }

  @override
  void render(Canvas canvas) {
    _textPaint?.render(canvas, text, position.position);
    super.render(canvas);
  }

  @override
  int get priority => LayerPriority.MAP + 1;
}
