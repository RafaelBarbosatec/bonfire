import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

enum BarLifeDrawPorition { top, bottom, left, right }

typedef BarLifeTextBuilder = String Function(double life, double maxLife);

class BarLifeComponent extends GameComponent {
  Paint _barLifeBgPaint = Paint();
  final Paint _barLifePaint = Paint()..style = PaintingStyle.fill;
  Paint _barLifeBorderPaint = Paint();

  final BarLifeDrawPorition drawPosition;
  final List<Color>? colors;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color borderColor;
  final bool showLifeText;
  final TextStyle? textStyle;
  final BarLifeTextBuilder? barLifeTextBuilder;
  double _life = 100;
  double _maxLife = 100;

  double get life => _life;
  bool show = true;

  Vector2 _textSize = Vector2.zero();
  Vector2 _textOffset = Vector2.zero();

  TextPaint _textConfig = TextPaint();
  final GameComponent target;

  BarLifeComponent({
    required this.target,
    required Vector2 size,
    Vector2? position,
    Vector2? textOffset,
    this.drawPosition = BarLifeDrawPorition.top,
    this.colors,
    this.textStyle,
    this.showLifeText = true,
    this.backgroundColor = const Color(0xFF000000),
    this.borderRadius = BorderRadius.zero,
    this.borderWidth = 2,
    this.borderColor = const Color(0xFFFFFFFF),
    this.barLifeTextBuilder,
    double life = 100,
    double maxLife = 100,
  }) {
    _life = life;
    _maxLife = maxLife;
    _textOffset = textOffset ?? _textOffset;
    _barLifeBorderPaint = _barLifeBorderPaint
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    _barLifeBgPaint = _barLifeBgPaint
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    this.position = position ?? Vector2.zero();
    this.size = size;

    _textConfig = TextPaint(
      style: textStyle?.copyWith(fontSize: size.y * 0.8) ??
          TextStyle(fontSize: size.y * 0.8, color: Colors.white),
    );

    _textSize = _textConfig.getLineMetrics(_getLifeText()).size;
  }

  @override
  void render(Canvas canvas) {
    double yPosition = (y - height);

    double xPosition = x;
    switch (drawPosition) {
      case BarLifeDrawPorition.top:
        break;
      case BarLifeDrawPorition.bottom:
        yPosition = target.size.y + y;
        break;
      case BarLifeDrawPorition.left:
        xPosition = -width + x;
        yPosition = (target.size.y / 2 - height / 2) + y;
        break;
      case BarLifeDrawPorition.right:
        xPosition = width + x;
        yPosition = (target.size.y / 2 - height / 2) + y;
        break;
    }

    double currentBarLife = (_life * width) / _maxLife;

    if (borderWidth > 0) {
      final RRect borderRect = borderRadius.toRRect(
        Rect.fromLTWH(
          xPosition,
          yPosition,
          width,
          height,
        ),
      );

      canvas.drawRRect(
        borderRect,
        _barLifeBorderPaint,
      );
    }

    final RRect bgRect = borderRadius.toRRect(Rect.fromLTWH(
      xPosition,
      yPosition,
      width,
      height,
    ));

    canvas.drawRRect(
      bgRect,
      _barLifeBgPaint,
    );

    final RRect lifeRect = borderRadius.toRRect(Rect.fromLTWH(
      xPosition,
      yPosition,
      currentBarLife,
      height,
    ));

    canvas.drawRRect(
      lifeRect,
      _barLifePaint
        ..color = _getColorLife(
          currentBarLife,
          width,
          colors ??
              [
                const Color(0xFFF44336),
                const Color(0xFFFFEB3B),
                const Color(0xFF4CAF50),
              ],
        ),
    );

    if (showLifeText) {
      double xText = _textOffset.x + xPosition + (width - _textSize.x) / 2;
      double yText = _textOffset.y + yPosition + (height - _textSize.y) / 2;
      _textConfig.render(
        canvas,
        _getLifeText(),
        Vector2(xText, yText),
      );
    }

    super.render(canvas);
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

  void updateLife(double life) {
    _life = life;
    _textSize = _textConfig.getLineMetrics(_getLifeText()).size;
  }

  void updatemaxLife(double life) {
    _maxLife = life;
  }

  String _getLifeText() {
    return barLifeTextBuilder?.call(_life, _maxLife) ??
        '${_life.toInt()}/${_maxLife.toInt()}';
  }
}
