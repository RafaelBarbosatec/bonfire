import 'dart:math';

import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/text_damage.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension EnemyExtensions on Enemy {
  void seePlayer({
    Function(Player) observed,
    Function() notObserved,
    int visionCells = 3,
  }) {
    Player player = gameRef.player;
    if (!isVisibleInMap() || player == null || this.position == null) return;

    if (player.isDead) {
      if (notObserved != null) notObserved();
      return;
    }

    double visionWidth = this.position.width * visionCells * 2;
    double visionHeight = this.position.height * visionCells * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      this.position.left - (visionWidth / 2),
      this.position.top - (visionHeight / 2),
      visionWidth,
      visionHeight,
    );

    if (fieldOfVision.overlaps(player.rectCollision)) {
      if (observed != null) observed(player);
    } else {
      if (notObserved != null) notObserved();
    }
  }

  Direction directionThatPlayerIs() {
    Player player = this.gameRef.player;
    var diffX = position.center.dx - player.position.center.dx;
    var diffPositiveX = diffX < 0 ? diffX *= -1 : diffX;
    var diffY = position.center.dy - player.position.center.dy;
    var diffPositiveY = diffY < 0 ? diffY *= -1 : diffY;

    if (diffPositiveX > diffPositiveY) {
      if (player.position.center.dx > position.center.dx) {
        return Direction.right;
      } else if (player.position.center.dx < position.center.dx) {
        return Direction.left;
      }
    } else {
      if (player.position.center.dy > position.center.dy) {
        return Direction.bottom;
      } else if (player.position.center.dy < position.center.dy) {
        return Direction.top;
      }
    }

    return Direction.left;
  }

  void showDamage(double damage,
      {TextConfig config = const TextConfig(
        fontSize: 10,
        color: Colors.white,
      )}) {
    gameRef.add(
      TextDamage(
        damage.toInt().toString(),
        Position(
          positionInWorld.center.dx,
          positionInWorld.top,
        ),
        config: config,
      ),
    );
  }

  void drawDefaultLifeBar(
    Canvas canvas, {
    bool drawInBottom = false,
    double padding = 5,
    double strokeWidth = 2,
  }) {
    if (this.position == null) return;
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

  double getAngleFomPlayer() {
    Player player = this.gameRef.player;
    if (player == null) return 0.0;
    return atan2(
      player.rectCollisionInWorld.center.dy - this.positionInWorld.center.dy,
      player.rectCollisionInWorld.center.dx - this.positionInWorld.center.dx,
    );
  }
}
