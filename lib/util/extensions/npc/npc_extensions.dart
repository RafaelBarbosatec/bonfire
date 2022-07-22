import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/geometry/shape.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 22/03/22

extension NpcExtensions on Npc {
  /// This method we notify when detect the player when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  Shape? seePlayer({
    required Function(Player) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
  }) {
    Player? player = gameRef.player;
    if (player == null || player.isDead) {
      notObserved?.call();
      return null;
    }
    return this.seeComponent(
      player,
      observed: (c) => observed(c as Player),
      notObserved: notObserved,
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle ?? this.lastDirection.toRadians(),
    );
  }

  /// Checks whether the player is within range. If so, move to it.
  Shape? seeAndMoveToPlayer({
    required Function(Player) closePlayer,
    VoidCallback? notObserved,
    VoidCallback? observed,
    double radiusVision = 32,
    double margin = 10,
    double? visionAngle,
    double? angle,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (runOnlyVisibleInScreen && !this.isVisible) return null;

    return seePlayer(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle,
      observed: (player) {
        observed?.call();
        this.followComponent(
          player,
          dtUpdate,
          closeComponent: (comp) => closePlayer(comp as Player),
          margin: margin,
        );
      },
      notObserved: () {
        if (!this.isIdle) {
          this.idle();
        }
        notObserved?.call();
      },
    );
  }

  /// Checks whether the player is within range. If so, move to it.
  void seeAndMoveToEnemy({
    required Function(Enemy) closeEnemy,
    VoidCallback? notObserved,
    VoidCallback? observed,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (runOnlyVisibleInScreen && !this.isVisible) return;

    seeComponentType<Enemy>(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle ?? lastDirection.toRadians(),
      observed: (enemy) {
        observed?.call();
        this.followComponent(
          enemy.first,
          dtUpdate,
          closeComponent: (comp) => closeEnemy(comp as Enemy),
          margin: margin,
        );
      },
      notObserved: () {
        if (!this.isIdle) {
          this.idle();
        }
        notObserved?.call();
      },
    );
  }

  /// Checks whether the ally is within range. If so, move to it.
  void seeAndMoveToAlly({
    required Function(Ally) closeAlly,
    VoidCallback? notObserved,
    VoidCallback? observed,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (runOnlyVisibleInScreen && !this.isVisible) return;

    seeComponentType<Ally>(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle ?? lastDirection.toRadians(),
      observed: (ally) {
        observed?.call();
        this.followComponent(
          ally.first,
          dtUpdate,
          closeComponent: (comp) => closeAlly(comp as Ally),
          margin: margin,
        );
      },
      notObserved: () {
        if (!this.isIdle) {
          this.idle();
        }
        notObserved?.call();
      },
    );
  }

  /// Get angle between enemy and player
  /// player as a base
  double getAngleFromPlayer() {
    Player? player = this.gameRef.player;
    if (player == null) return 0.0;
    return atan2(
      playerRect.center.dy - rectConsideringCollision.center.dy,
      playerRect.center.dx - rectConsideringCollision.center.dx,
    );
  }

  /// Get angle between enemy and player
  /// enemy position as a base
  double getInverseAngleFromPlayer() {
    Player? player = this.gameRef.player;
    if (player == null) return 0.0;
    return atan2(
      this.position.y - playerRect.center.dy,
      this.position.x - playerRect.center.dx,
    );
  }

  /// Gets player position used how base in calculations
  Rect get playerRect {
    return (gameRef.player is ObjectCollision
            ? (gameRef.player as ObjectCollision).rectCollision
            : gameRef.player?.toRect()) ??
        Rect.zero;
  }
}
