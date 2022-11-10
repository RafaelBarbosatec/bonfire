import 'package:bonfire/mixins/attackable.dart';
import 'package:flutter/widgets.dart';

Paint _barLiveBgPaint = Paint();
Paint _barLivePaint = Paint();
Paint _barLiveBorderPaint = Paint();

extension AttackableExtensions on Attackable {
  /// Draw simple life bar
  @Deprecated('Please use UseBarLife mixin')
  void drawDefaultLifeBar(
    Canvas canvas, {
    Offset align = Offset.zero,
    bool drawInBottom = false,
    double margin = 4,
    double height = 4,
    double? width,
    List<Color>? colorsLife,
    Color backgroundColor = const Color(0xFF000000),
    BorderRadius borderRadius = BorderRadius.zero,
    double borderWidth = 0,
    Color borderColor = const Color(0xFFFFFFFF),
  }) {
    double yPosition = (y - height) - margin;

    double xPosition = x + align.dx;

    if (drawInBottom) {
      yPosition = toRect().bottom + margin;
    }

    yPosition = yPosition - align.dy;

    final w = width ?? this.width;

    double currentBarLife = (life * w) / maxLife;

    if (borderWidth > 0) {
      final RRect borderRect = borderRadius.toRRect(Rect.fromLTWH(
        xPosition,
        yPosition,
        w,
        height,
      ));

      canvas.drawRRect(
        borderRect,
        _barLiveBorderPaint
          ..color = borderColor
          ..strokeWidth = borderWidth
          ..style = PaintingStyle.stroke,
      );
    }

    final RRect bgRect = borderRadius.toRRect(Rect.fromLTWH(
      xPosition,
      yPosition,
      w,
      height,
    ));

    canvas.drawRRect(
      bgRect,
      _barLiveBgPaint
        ..color = backgroundColor
        ..style = PaintingStyle.fill,
    );

    final RRect lifeRect = borderRadius.toRRect(Rect.fromLTWH(
      xPosition,
      yPosition,
      currentBarLife,
      height,
    ));

    canvas.drawRRect(
      lifeRect,
      _barLivePaint
        ..color = _getColorLife(
          currentBarLife,
          w,
          colorsLife ??
              [
                const Color(0xFFF44336),
                const Color(0xFFFFEB3B),
                const Color(0xFF4CAF50),
              ],
        )
        ..style = PaintingStyle.fill,
    );
  }

  Color _getColorLife(
    double currentBarLife,
    double maxWidth,
    List<Color> colors,
  ) {
    final parts = maxWidth / colors.length;
    int index = (currentBarLife / parts).ceil() - 1;
    if (index < 0) {
      return colors[0];
    }
    if (index > colors.length - 1) {
      return colors.last;
    }
    return colors[index];
  }
}
