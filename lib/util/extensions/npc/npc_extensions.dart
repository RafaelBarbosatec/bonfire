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
  /// [visionAngle] in radians
  /// [angle] in radians. is automatically picked up using the component's direction.
  Shape? seePlayer({
    required Function(Player) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
  }) {
    final player = gameRef.player;
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
    Function(Player)? closePlayer,
    // return true to stop move.
    BoolCallback? notObserved,
    VoidCallback? observed,
    VoidCallback? notCanMove,
    double radiusVision = 32,
    double margin = 2,
    double? visionAngle,
    double? angle,
    bool runOnlyVisibleInScreen = true,
    MovementAxis movementAxis = MovementAxis.all,
  }) {
    if (runOnlyVisibleInScreen && !isVisible) {
      return null;
    }

    return seePlayer(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle,
      observed: (player) {
        observed?.call();
        final move = moveTowardsTarget(
          target: player,
          close: () => closePlayer?.call(player),
          margin: margin,
          movementAxis: movementAxis,
        );
        if (!move) {
          notCanMove?.call();
        }
      },
      notObserved: () {
        final stop = notObserved?.call() ?? true;
        if (stop) {
          stopMove();
        }
      },
    );
  }

  /// Checks whether the player is within range. If so, move to it.
  /// [visionAngle] in radians
  /// [angle] in radians. is automatically picked up using the component's direction.
  void seeAndMoveToEnemy({
    required Function(Enemy) closeEnemy,
    // return true to stop move.
    BoolCallback? notObserved,
    VoidCallback? observed,
    VoidCallback? notCanMove,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
    MovementAxis movementAxis = MovementAxis.all,
  }) {
    if (runOnlyVisibleInScreen && !isVisible) {
      return;
    }

    seeComponentType<Enemy>(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle ?? lastDirection.toRadians(),
      observed: (enemy) {
        observed?.call();
        final move = moveTowardsTarget(
          target: enemy.first,
          close: () {
            closeEnemy(enemy.first);
          },
          margin: margin,
          movementAxis: movementAxis,
        );
        if (!move) {
          notCanMove?.call();
        }
      },
      notObserved: () {
        final stop = notObserved?.call() ?? true;
        if (stop) {
          stopMove();
        }
      },
    );
  }

  /// Checks whether the ally is within range. If so, move to it.
  /// [visionAngle] in radians
  /// [angle] in radians. is automatically picked up using the component's direction.
  void seeAndMoveToAlly({
    required Function(Ally) closeAlly,
    // return true to stop move.
    BoolCallback? notObserved,
    VoidCallback? observed,
    VoidCallback? notCanMove,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
    MovementAxis movementAxis = MovementAxis.all,
  }) {
    if (runOnlyVisibleInScreen && !isVisible) {
      return;
    }

    seeComponentType<Ally>(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle ?? lastDirection.toRadians(),
      observed: (ally) {
        observed?.call();
        final move = moveTowardsTarget(
          target: ally.first,
          close: () {
            closeAlly(ally.first);
          },
          movementAxis: movementAxis,
          margin: margin,
        );
        if (!move) {
          notCanMove?.call();
        }
      },
      notObserved: () {
        final stop = notObserved?.call() ?? true;
        if (stop) {
          stopMove();
        }
      },
    );
  }

  /// Gives the direction of the player in relation to this component
  Direction? getDirectionToPlayer() {
    final player = gameRef.player;
    if (player == null) {
      return null;
    }
    return getDirectionToTarget(player);
  }

  /// Get angle between enemy and player
  /// player as a base
  double getAngleToPlayer() {
    final player = gameRef.player;
    if (player == null) {
      return 0.0;
    }
    return getAngleToTarget(player);
  }

  /// Get angle between enemy and player
  /// enemy position as a base
  double getInverseAngleToPlayer() {
    final player = gameRef.player;
    if (player == null) {
      return 0.0;
    }
    return BonfireUtil.angleBetweenPoints(
      playerRect.center.toVector2(),
      rectCollision.centerVector2,
    );
  }

  /// Gets player position used how base in calculations
  Rect get playerRect {
    return gameRef.player?.rectCollision ?? Rect.zero;
  }
}
