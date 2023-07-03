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
  void moveTowardsTarget<T extends GameComponent>({
    required T target,
    Function? close,
    double margin = 0,
  }) {
    double radAngle = getAngleFromPlayer();

    Rect rectPlayerCollision = target.rectConsideringCollision.inflate(margin);

    if (rectConsideringCollision.overlaps(rectPlayerCollision)) {
      close?.call();
      moveFromAngle(radAngle);
      stopMove();
      return;
    }
    moveFromAngle(radAngle);
  }

  /// This method we notify when detect the player when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  /// [visionAngle] in radians
  /// [angle] in radians. is automatically picked up using the component's direction.
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
    return seeComponent(
      player,
      observed: (c) => observed(c as Player),
      notObserved: notObserved,
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle ?? lastDirection.toRadians(),
    );
  }

  /// Checks whether the player is within range. If so, move to it.
  /// [visionAngle] in radians
  /// [angle] in radians. is automatically picked up using the component's direction.
  Shape? seeAndMoveToPlayer({
    required Function(Player) closePlayer,
    VoidCallback? notObserved,
    VoidCallback? observed,
    VoidCallback? notCanMove,
    double radiusVision = 32,
    double margin = 10,
    double? visionAngle,
    double? angle,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (runOnlyVisibleInScreen && !isVisible) return null;

    return seePlayer(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle,
      observed: (player) {
        observed?.call();
        moveTowardsTarget(
          target: player,
          close: () => closePlayer(player),
          margin: margin,
        );
      },
      notObserved: () {
        stopMove();
        notObserved?.call();
      },
    );
  }

  /// Checks whether the player is within range. If so, move to it.
  /// [visionAngle] in radians
  /// [angle] in radians. is automatically picked up using the component's direction.
  void seeAndMoveToEnemy({
    required Function(Enemy) closeEnemy,
    VoidCallback? notObserved,
    VoidCallback? observed,
    VoidCallback? notCanMove,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (runOnlyVisibleInScreen && !isVisible) return;

    seeComponentType<Enemy>(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle ?? lastDirection.toRadians(),
      observed: (enemy) {
        observed?.call();
        moveTowardsTarget(
          target: enemy.first,
          close: () {
            closeEnemy(enemy.first);
          },
          margin: margin,
        );
      },
      notObserved: () {
        stopMove();
        notObserved?.call();
      },
    );
  }

  /// Checks whether the ally is within range. If so, move to it.
  /// [visionAngle] in radians
  /// [angle] in radians. is automatically picked up using the component's direction.
  void seeAndMoveToAlly({
    required Function(Ally) closeAlly,
    VoidCallback? notObserved,
    VoidCallback? observed,
    VoidCallback? notCanMove,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (runOnlyVisibleInScreen && !isVisible) return;

    seeComponentType<Ally>(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle ?? lastDirection.toRadians(),
      observed: (ally) {
        observed?.call();
        moveTowardsTarget(
          target: ally.first,
          close: () {
            closeAlly(ally.first);
          },
          margin: margin,
        );
      },
      notObserved: () {
        stopMove();
        notObserved?.call();
      },
    );
  }

  /// Get angle between enemy and player
  /// player as a base
  double getAngleFromPlayer() {
    Player? player = gameRef.player;
    if (player == null) return 0.0;
    return BonfireUtil.angleBetweenPoints(
      rectConsideringCollision.center.toVector2(),
      playerRect.center.toVector2(),
    );
  }

  /// Get angle between enemy and player
  /// enemy position as a base
  double getInverseAngleFromPlayer() {
    Player? player = gameRef.player;
    if (player == null) return 0.0;
    return BonfireUtil.angleBetweenPoints(
      playerRect.center.toVector2(),
      rectConsideringCollision.center.toVector2(),
    );
  }

  /// Gets player position used how base in calculations
  Rect get playerRect {
    return gameRef.player?.rectConsideringCollision ?? Rect.zero;
  }
}
