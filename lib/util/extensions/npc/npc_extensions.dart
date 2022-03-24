import 'dart:ui';

import 'package:bonfire/bonfire.dart';

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
  void seePlayer({
    required Function(Player) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
  }) {
    Player? player = gameRef.player;
    if (player == null || player.isDead) {
      notObserved?.call();
      return;
    }
    this.seeComponent(
      player,
      observed: (c) => observed(c as Player),
      notObserved: notObserved,
      radiusVision: radiusVision,
    );
  }

  /// Checks whether the player is within range. If so, move to it.
  void seeAndMoveToPlayer({
    required Function(Player) closePlayer,
    VoidCallback? notObserved,
    VoidCallback? observed,
    double radiusVision = 32,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (runOnlyVisibleInScreen && !this.isVisible) return;

    seePlayer(
      radiusVision: radiusVision,
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
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (runOnlyVisibleInScreen && !this.isVisible) return;

    seeComponentType<Enemy>(
      radiusVision: radiusVision,
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
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (runOnlyVisibleInScreen && !this.isVisible) return;

    seeComponentType<Ally>(
      radiusVision: radiusVision,
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
}
