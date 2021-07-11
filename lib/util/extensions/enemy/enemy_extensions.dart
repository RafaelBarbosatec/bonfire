import 'dart:math';

import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/extensions/game_component_extensions.dart';
import 'package:bonfire/util/functions.dart';
import 'package:bonfire/util/vector2rect.dart';
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
    this.seeComponent(
      player,
      observed: (c) => observed(c as Player),
      radiusVision: radiusVision,
    );
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

  Direction getPlayerDirection() {
    Vector2Rect rectToMove = getRectAndCollision(this);
    double centerXPlayer = playerRect.center.dx;
    double centerYPlayer = playerRect.center.dy;

    double centerYEnemy = rectToMove.center.dy;
    double centerXEnemy = rectToMove.center.dx;

    double diffX = centerXEnemy - centerXPlayer;
    double diffY = centerYEnemy - centerYPlayer;

    double positiveDiffX = diffX > 0 ? diffX : diffX * -1;
    double positiveDiffY = diffY > 0 ? diffY : diffY * -1;
    if (positiveDiffX > positiveDiffY) {
      return diffX > 0 ? Direction.left : Direction.right;
    } else {
      return diffY > 0 ? Direction.up : Direction.down;
    }
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
