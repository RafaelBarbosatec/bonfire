import 'dart:math';

import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/text_damage_component.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    bool drawInBottom = false,
    double padding = 5,
    double strokeWidth = 2,
  }) {
    double yPosition = position.top - padding;

    if (drawInBottom) {
      yPosition = position.bottom + padding;
    }

    canvas.drawLine(
        Offset(position.left, yPosition),
        Offset(position.left + position.width, yPosition),
        Paint()
          ..color = Colors.black
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.fill);

    double currentBarLife = (life * position.width) / maxLife;

    canvas.drawLine(
        Offset(position.left, yPosition),
        Offset(position.left + currentBarLife, yPosition),
        Paint()
          ..color = _getColorLife(currentBarLife)
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.fill);
  }

  Color _getColorLife(double currentBarLife) {
    if (currentBarLife > width - (width / 3)) {
      return Colors.green;
    }
    if (currentBarLife > (width / 3)) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
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
