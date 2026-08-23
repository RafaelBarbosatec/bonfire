import 'package:flutter/material.dart';
import 'package:turn_game/util/player_turn.dart';
import 'package:turn_game/util/player_ally.dart';

abstract class PlayerEnemy extends PlayerTurn {
  @override
  // ignore: overridden_fields
  final Paint rectPaint = Paint()
    ..color = Colors.red.withValues(alpha: 0.5);

  PlayerEnemy({
    required super.position,
    required super.size,
    required super.animation,
  });

  @override
  void doAttackChar(PlayerTurn char) {
    if (char is PlayerAlly) {
      doAttackAlly(char);
    }
  }

  void doAttackAlly(PlayerAlly ally);
}
