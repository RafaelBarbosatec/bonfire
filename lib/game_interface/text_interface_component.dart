import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/game_interface/interface_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Component used to add Text in your [GameInterface]
class TextInterfaceComponent extends InterfaceComponent {
  String text;
  late TextPaint textConfig;
  TextInterfaceComponent({
    required int id,
    required Vector2 position,
    this.text = '',
    double width = 0,
    double height = 0,
    ValueChanged<bool>? onTapComponent,
    TextPaintConfig? textConfig,
  }) : super(
          id: id,
          position: position,
          width: width,
          height: height,
          onTapComponent: onTapComponent,
        ) {
    this.textConfig = TextPaint(config: textConfig ?? TextPaintConfig());
  }

  @override
  void render(Canvas canvas) {
    textConfig.render(
      canvas,
      text,
      Vector2(this.position.left, this.position.top),
    );
    super.render(canvas);
  }
}
