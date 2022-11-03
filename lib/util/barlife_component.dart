import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class BarLifeComponent extends GameComponent with Follower {
  final Paint _barLiveBgPaint = Paint();
  final Paint _barLivePaint = Paint();
  final Paint _barLiveBorderPaint = Paint();

  final bool drawInBottom;
  final double margin;
  final List<Color>? colors;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color borderColor;
  double life;
  double maxLife;
  bool show = true;

  BarLifeComponent({
    required Vector2 size,
    Attackable? target,
    Vector2? offset,
    this.drawInBottom = false,
    this.margin = 4,
    this.colors,
    this.backgroundColor = const Color(0xFF000000),
    this.borderRadius = BorderRadius.zero,
    this.borderWidth = 2,
    this.borderColor = const Color(0xFFFFFFFF),
    this.life = 100,
    this.maxLife = 100,
  }) {
    this.size = size;
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

    if (drawInBottom) {
      yPosition = followerTarget!.bottom + margin;
    }

    yPosition = yPosition;

    double currentBarLife = (life * width) / maxLife;

    if (borderWidth > 0) {
      final RRect borderRect = borderRadius.toRRect(Rect.fromLTWH(
        xPosition,
        yPosition,
        width,
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
      width,
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
          width,
          colors ??
              [
                const Color(0xFFF44336),
                const Color(0xFFFFEB3B),
                const Color(0xFF4CAF50),
              ],
        )
        ..style = PaintingStyle.fill,
    );
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
}
