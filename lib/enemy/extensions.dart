import 'dart:math';

import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/text_damage_component.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Paint _barLiveBgPaint = Paint();
Paint _barLivePaint = Paint();
Paint _barLiveBorderPaint = Paint();

/// Functions util to use in your [Enemy]
extension EnemyExtensions on Enemy {
  /// This method we notify when detect the player when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  void seePlayer({
    required Function(Player) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
  }) {
    Player? player = gameRef.player;
    if (player == null) return;

    if (player.isDead) {
      if (notObserved != null) notObserved();
      return;
    }

    double vision = radiusVision * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      this.position.center.dx - radiusVision,
      this.position.center.dy - radiusVision,
      vision,
      vision,
    );

    if (fieldOfVision.overlaps(playerRect.rect)) {
      observed(player);
    } else {
      notObserved?.call();
    }
  }

  /// Add in the game a text with animation representing damage received
  void showDamage(
    double damage, {
    TextPaintConfig? config,
    double initVelocityTop = -5,
    double gravity = 0.5,
    double maxDownSize = 20,
    DirectionTextDamage direction = DirectionTextDamage.RANDOM,
    bool onlyUp = false,
  }) {
    gameRef.add(
      TextDamageComponent(
        damage.toInt().toString(),
        Vector2(
          position.center.dx,
          position.top,
        ),
        config: config ??
            TextPaintConfig(
              fontSize: 14,
              color: Colors.white,
            ),
        initVelocityTop: initVelocityTop,
        gravity: gravity,
        direction: direction,
        onlyUp: onlyUp,
        maxDownSize: maxDownSize,
      ),
    );
  }

  /// Draw simple life bar
  void drawDefaultLifeBar(
    Canvas canvas, {
    Offset align = Offset.zero,
    bool drawInBottom = false,
    double margin = 4,
    double height = 4,
    double? width,
    List<Color>? colorsLife,
    Color backgroundColor = Colors.black,
    BorderRadius borderRadius = BorderRadius.zero,
    double borderWidth = 0,
    Color borderColor = Colors.white,
  }) {
    double yPosition = (position.top - height) - margin;

    double xPosition = position.left + align.dx;

    if (drawInBottom) {
      yPosition = position.bottom + margin;
    }

    yPosition = yPosition - align.dy;

    final w = width ?? position.width;

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
          colorsLife ?? [Colors.red, Colors.yellow, Colors.green],
        )
        ..style = PaintingStyle.fill,
    );
  }

  Color _getColorLife(
      double currentBarLife, double maxWidth, List<Color> colors) {
    final parts = maxWidth / colors.length;
    int index = (currentBarLife / parts).floor() - 1;
    if (index < 0) return colors[0];
    return colors[index];
  }

  /// Get angle between enemy and player
  /// player as a base
  double getAngleFomPlayer() {
    Player? player = this.gameRef.player;
    if (player == null) return 0.0;
    return atan2(
      playerRect.center.dy - this.position.center.dy,
      playerRect.center.dx - this.position.center.dx,
    );
  }

  /// Get angle between enemy and player
  /// enemy position as a base
  double getInverseAngleFomPlayer() {
    Player? player = this.gameRef.player;
    if (player == null) return 0.0;
    return atan2(
      this.position.center.dy - playerRect.center.dy,
      this.position.center.dx - playerRect.center.dx,
    );
  }

  /// Gets player position used how base in calculations
  Vector2Rect get playerRect {
    return (gameRef.player is ObjectCollision
            ? (gameRef.player as ObjectCollision).rectCollision
            : gameRef.player?.position) ??
        Vector2Rect.zero();
  }
}
