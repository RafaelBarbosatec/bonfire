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
    textConfig.render(
      canvas,
      text,
      Vector2.zero(),
    );
  }

  @override
  void update(double dt) {
    if (size == Vector2.zero()) {
      _measuredWidth = textConfig.getLineMetrics(text).width;
      _measuredHeight = textConfig.getLineMetrics(text).height;
      size = Vector2(_measuredWidth!, _measuredHeight!);
    }
    super.update(dt);
  }
}
