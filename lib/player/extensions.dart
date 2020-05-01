import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/text_damage.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension PlayerExtensions on Player {
  void showDamage(double damage,
      {TextConfig config = const TextConfig(
        fontSize: 10,
        color: Colors.red,
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

  void seeEnemy({
    Function(List<Enemy>) observed,
    Function() notObserved,
    int visionCells = 3,
  }) {
    if (isDead || position == null) return;

    var enemiesInLife = this.gameRef.enemies.where((e) => !e.isDead);
    if (enemiesInLife.length == 0) {
      if (notObserved != null) notObserved();
      return;
    }

    double visionWidth = position.width * visionCells * 2;
    double visionHeight = position.height * visionCells * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      position.left - (visionWidth / 2),
      position.top - (visionHeight / 2),
      visionWidth,
      visionHeight,
    );

    List<Enemy> enemiesObserved = enemiesInLife
        .where((enemy) => fieldOfVision.overlaps(enemy.position))
        .toList();

    if (enemiesObserved.length > 0) {
      if (observed != null) observed(enemiesObserved);
    } else {
      if (notObserved != null) notObserved();
    }
  }
}
