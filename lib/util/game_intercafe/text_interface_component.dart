import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextInterfaceComponent extends InterfaceComponent {
  String text;
  final TextConfig textConfig;
  TextInterfaceComponent({
    @required int id,
    @required Position position,
    this.text = '',
    double width = 0,
    double height = 0,
    VoidCallback onTapComponent,
    this.textConfig = const TextConfig(),
  }) : super(
          id: id,
          position: position,
          width: width,
          height: height,
          onTapComponent: onTapComponent,
          sprite: null,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textConfig.render(
      canvas,
      text,
      Position(this.position.left, this.position.top),
    );
  }
}
