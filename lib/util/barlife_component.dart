import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

enum BarLifePorition { top, bottom }

typedef BarLifeTextBuilder = String Function(double life, double maxLife);

class BarLifeComponent extends GameComponent with Follower {
  Paint _barLiveBgPaint = Paint();
  final Paint _barLivePaint = Paint()..style = PaintingStyle.fill;
  Paint _barLiveBorderPaint = Paint();

  final BarLifePorition drawPosition;
  final double margin;
  final List<Color>? colors;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color borderColor;
  final bool showLifeText;
  final TextStyle? textStyle;
  final BarLifeTextBuilder? barLifetextBuilder;
  double _life = 100;
  double _maxLife = 100;

  double get life => _life;
  bool show = true;

  Vector2 _textSize = Vector2.zero();
  Vector2 _textOffset = Vector2.zero();

  TextPaint _textConfig = TextPaint();

  BarLifeComponent({
    required Vector2 size,
    Attackable? target,
    Vector2? offset,
    Vector2? textOffset,
    this.drawPosition = BarLifePorition.top,
    this.margin = 4,
    this.colors,
    this.textStyle,
    this.showLifeText = true,
    this.backgroundColor = const Color(0xFF000000),
    this.borderRadius = BorderRadius.zero,
    this.borderWidth = 2,
    this.borderColor = const Color(0xFFFFFFFF),
    this.barLifetextBuilder,
    double life = 100,
    double maxLife = 100,
  }) {
    _life = life;
    _maxLife = maxLife;
    _textOffset = textOffset ?? _textOffset;
    _barLiveBorderPaint = _barLiveBorderPaint
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    _barLiveBgPaint = _barLiveBgPaint
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    this.size = size;

    _textConfig = TextPaint(
      style: textStyle?.copyWith(fontSize: size.y * 0.8) ??
          TextStyle(fontSize: size.y * 0.8, color: Colors.white),
    );

    _textSize = _textConfig.measureText(_getLifeText());

    setupFollower(
      target: target,
      offset: offset,
    );
  }

  @override
  void render(Canvas canvas) {
    if (followerTarget == null || !show) {
      return;
    }
    double yPosition = (y - height) - margin;

    double xPosition = (followerTarget!.width - width) / 2 + x;

    if (drawPosition == BarLifePorition.bottom) {
      yPosition = followerTarget!.bottom + (followerOffset?.y ?? 0.0) + margin;
    }

    yPosition = yPosition;

    double currentBarLife = (_life * width) / _maxLife;

    if (borderWidth > 0) {
      final RRect borderRect = borderRadius.toRRect(Rect.fromLTWH(
        xPosition,
        yPosition,
        width,
        height,
      ));

      canvas.drawRRect(
        borderRect,
        _barLiveBorderPaint,
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
      _barLiveBgPaint,
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
    _textSize = _textConfig.measureText(_getLifeText());
  }

  void updatemaxLife(double life) {
    _maxLife = life;
  }

  String _getLifeText() {
    return barLifetextBuilder?.call(_life, _maxLife) ??
        '${_life.toInt()}/${_maxLife.toInt()}';
  }
}
