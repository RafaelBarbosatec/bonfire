import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

/// Component used to add Text in your [GameInterface]
class TextInterfaceComponent extends InterfaceComponent {
  String text;
  double? _measuredWidth;
  double? _measuredHeight;
  late TextPaint textConfig;
  TextInterfaceComponent({
    required int id,
    required Vector2 position,
    this.text = '',
    ValueChanged<bool>? onTapComponent,
    TextStyle? textConfig,
  }) : super(
          id: id,
          position: position,
          size: Vector2.zero(),
          onTapComponent: onTapComponent,
        ) {
    this.textConfig = TextPaint(style: textConfig);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_measuredWidth == null) {
      _measuredWidth = textConfig.measureTextWidth(text);
      _measuredHeight = textConfig.measureTextHeight(text);
      size = Vector2(_measuredWidth!, _measuredHeight!);
    }

    textConfig.render(
      canvas,
      text,
      Vector2(x, y),
    );
  }
}
