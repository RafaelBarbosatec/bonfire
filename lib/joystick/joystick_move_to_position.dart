import 'dart:ui';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class JoystickMoveToPosition extends JoystickController {
  final double tileSize;
  int? _pointer;

  JoystickMoveToPosition(this.tileSize);

  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}

  @override
  void handlerPointerDown(PointerDownEvent event) {
    _pointer = event.pointer;
    super.handlerPointerDown(event);
  }

  @override
  void handlerPointerUp(PointerUpEvent event) {
    if (_pointer == event.pointer) {
      _calculatePath(event);
    }
    super.handlerPointerUp(event);
  }

  void _calculatePath(PointerUpEvent event) {
    final camera = this.gameRef.camera;
    final absolutePosition = camera.screenPositionToWorld(event.position);

    final tiledCollisionTouched =
        this.gameRef.map.getCollisionsRendered().where((element) {
      return (element is ObjectCollision &&
          element.containCollision() &&
          element.position.contains(absolutePosition));
    });

    if (tiledCollisionTouched.isEmpty && gameRef.player != null) {
      final player = gameRef.player!;

      final positionPlayer = player is ObjectCollision
          ? (player as ObjectCollision).rectCollision.center
          : player.position.center;

      Offset playerPosition = _getCenterPositionByTileAndInvert(positionPlayer);

      Offset targetPosition =
          _getCenterPositionByTileAndInvert(absolutePosition);

      int columns = (playerPosition.dy > targetPosition.dy
              ? playerPosition.dy
              : targetPosition.dy)
          .toInt();
      int rows = (playerPosition.dx > targetPosition.dx
              ? playerPosition.dx
              : targetPosition.dx)
          .toInt();

      List<Offset> barriers = gameRef.visibleCollisions().map((e) {
        return _getCenterPositionByTileAndInvert(e.position.center);
      }).toList();

      List<Offset> result = [];
      List<Offset> path = [];
      try {
        result = AStar(
          rows: rows + 1,
          columns: columns + 1,
          start: playerPosition,
          end: targetPosition,
          barriers: barriers,
        ).findThePath();
        path.add(playerPosition);
        path.addAll(result.reversed);
        path.add(targetPosition);
        path = path.map((e) {
          return Offset(e.dy * tileSize, e.dx * tileSize)
              .translate(tileSize / 2, tileSize / 2);
        }).toList();
      } catch (e) {
        print('ERROR(AStar):$e');
      }

      gameRef.map.setLinePath(path);
      moveTo(absolutePosition.toVector2(), path);
    }
  }

  Offset _getCenterPositionByTileAndInvert(Offset center) {
    return Offset(
      (center.dy / tileSize).floor().toDouble(),
      (center.dx / tileSize).floor().toDouble(),
    );
  }
}
