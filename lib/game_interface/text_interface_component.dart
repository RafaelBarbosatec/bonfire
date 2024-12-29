import 'package:bonfire/bonfire.dart';

/// Component used to add Text in your [GameInterface]
class TextInterfaceComponent extends InterfaceComponent {
  String text;
  late TextPaint textConfig;
  TextInterfaceComponent({
    required super.id,
    required super.position,
    this.text = '',
    super.onTapComponent,
    TextStyle? textConfig,
  }) : super(
          size: Vector2.zero(),
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
      size = Vector2(
        textConfig.getLineMetrics(text).width,
        textConfig.getLineMetrics(text).height,
      );
    }
    super.update(dt);
  }
}
