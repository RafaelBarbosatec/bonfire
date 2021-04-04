import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/game_interface/interface_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextInterfaceComponent extends InterfaceComponent {
  String text;
  late TextConfig textConfig;
  TextInterfaceComponent({
    required int id,
    required Vector2 position,
    this.text = '',
    double width = 0,
    double height = 0,
    VoidCallback? onTapComponent,
    TextConfig? textConfig,
  }) : super(
          id: id,
          position: position,
          width: width,
          height: height,
          onTapComponent: onTapComponent,
        ) {
    this.textConfig = textConfig ?? TextConfig();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textConfig.render(
      canvas,
      text,
      Vector2(this.position.left, this.position.top),
    );
  }
}
