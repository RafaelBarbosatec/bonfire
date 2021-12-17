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
  final String name;
  TextGameComponent({
    required this.text,
    required Vector2 position,
    this.name = '',
    TextStyle? style,
  }) {
    this.position = position;
    _textPaint = TextPaint(
      style: style,
    );
  }

  @override
  void render(Canvas canvas) {
    _textPaint?.render(canvas, text, position);
    super.render(canvas);
  }

  @override
  int get priority => LayerPriority.MAP + 1;
}
