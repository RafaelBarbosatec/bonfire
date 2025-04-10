import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

enum BarLifeDrawPosition { top, bottom, left, right }

typedef BarLifeTextBuilder = String Function(double life, double maxLife);

class BarLifeComponent extends GameComponent {
  Paint _barLifeBgPaint = Paint();
  final Paint _barLifePaint = Paint()..style = PaintingStyle.fill;
  Paint _barLifeBorderPaint = Paint();

  final BarLifeDrawPosition drawPosition;
  final List<Color>? colors;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color borderColor;
  final bool showLifeText;
  final TextStyle? textStyle;
  final BarLifeTextBuilder? barLifeTextBuilder;
  EdgeInsets padding = EdgeInsets.zero;
  double _life = 100;
  double _maxLife = 100;

  double get life => _life;
  bool show = true;

  Vector2 _textSize = Vector2.zero();

  TextPaint _textConfig = TextPaint();
  final GameComponent target;

  BarLifeComponent({
    required this.target,
    Vector2? offset,
    this.drawPosition = BarLifeDrawPosition.top,
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
    EdgeInsets? padding,
    Vector2? size,
  }) {
    _life = life;
    _maxLife = maxLife;
    _barLifeBorderPaint = _barLifeBorderPaint
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    _barLifeBgPaint = _barLifeBgPaint
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    position = offset ?? Vector2.zero();

    _textConfig = TextPaint(
      style: textStyle ??
          TextStyle(
            fontSize: size?.x ?? target.width * 0.2,
            color: Colors.white,
          ),
    );

    if (size != null) {
      this.size = size;
    } else {
      _textSize = _textConfig.getLineMetrics(_getLifeText()).size;
      final horizontal = _textSize.x * 0.2;
      this.padding = padding ??
          EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: horizontal / 2,
          );
      this.size = Vector2(
        _textSize.x + this.padding.horizontal,
        _textSize.y + this.padding.vertical,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    var yPosition = y - height;
    var xPosition = (target.size.x - width) / 2;
    switch (drawPosition) {
      case BarLifeDrawPosition.top:
        break;
      case BarLifeDrawPosition.bottom:
        yPosition = target.size.y + y;
        break;
      case BarLifeDrawPosition.left:
        xPosition = -width + x;
        yPosition = (target.size.y / 2 - height / 2) + y;
        break;
      case BarLifeDrawPosition.right:
        xPosition = width + x;
        yPosition = (target.size.y / 2 - height / 2) + y;
        break;
    }

    final currentBarLife = (_life * width) / _maxLife;

    if (borderWidth > 0) {
      final borderRect = borderRadius.toRRect(
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

    final bgRect = borderRadius.toRRect(
      Rect.fromLTWH(
        xPosition,
        yPosition,
        width,
        height,
      ),
    );

    canvas.drawRRect(
      bgRect,
      _barLifeBgPaint,
    );

    final lifeRect = borderRadius.toRRect(
      Rect.fromLTWH(
        xPosition,
        yPosition,
        currentBarLife,
        height,
      ),
    );

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
      final xText = padding.left + xPosition;
      final yText = padding.top + yPosition;
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
    final index = (currentBarLife / parts).ceil() - 1;
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
