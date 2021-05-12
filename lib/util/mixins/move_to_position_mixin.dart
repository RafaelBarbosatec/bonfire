import 'dart:ui';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/component_movimantation.dart';
import 'package:flutter/material.dart';

mixin MoveToPositionMixin on GameComponent {
  List<Offset> _currentPath = [];
  int _currentIndex = 0;
  double speed = 0;
  ComponentMovement? component;

  Color pathLineColor = Colors.lightBlueAccent.withOpacity(0.5);
  double pathLineStrokeWidth = 4;

  void moveAlongThePath(
    Vector2 position,
    double speed,
  ) {
    if (this is ComponentMovement) {
      component = this as ComponentMovement;
      _calculatePath(position.toOffset());
      _currentIndex = 0;
      this.speed = speed;
    } else {
      print(
          'It was not possible to move components to the point. Implement "ComponentMovement" in its class');
    }
  }

  @override
  void update(double dt) {
    if (_currentPath.isNotEmpty) {
      _move(dt);
    }
    super.update(dt);
  }

  void stopMoveAlongThePath() {
    _currentPath.clear();
    _currentIndex = 0;
    component?.idle();
  }

  void _move(double dt) {
    double innerSpeed = speed * dt;

    Vector2Rect componentPosition = position;
    if (this is ObjectCollision) {
      componentPosition = (this as ObjectCollision).rectCollision;
    }
    double diffX = _currentPath[_currentIndex].dx - componentPosition.center.dx;
    double diffY = _currentPath[_currentIndex].dy - componentPosition.center.dy;
    double displacementX = diffX.abs() > innerSpeed ? speed : diffX.abs() / dt;
    double displacementY = diffY.abs() > innerSpeed ? speed : diffY.abs() / dt;

    if (diffX.abs() < 0.5 && diffY.abs() < 0.5) {
      if (_currentIndex < _currentPath.length - 1) {
        _currentIndex++;
      } else {
        stopMoveAlongThePath();
      }
    } else {
      if (diffX > 0 && diffX.abs() > 0.5) {
        component?.moveRight(displacementX);
      }
      if (diffX < 0 && diffX.abs() > 0.5) {
        component?.moveLeft(displacementX);
      }

      if (diffY > 0 && diffY.abs() > 0.5) {
        component?.moveDown(displacementY);
      }
      if (diffY < 0 && diffY.abs() > 0.5) {
        component?.moveUp(displacementY);
      }
    }
  }

  void _calculatePath(Offset finalPosition) {
    final tiledCollisionTouched =
        this.gameRef.map.getCollisionsRendered().where(
      (element) {
        return (element is ObjectCollision &&
            element.containCollision() &&
            element.position.contains(finalPosition));
      },
    );

    if (tiledCollisionTouched.isEmpty && gameRef.player != null) {
      final player = this;

      final positionPlayer = player is ObjectCollision
          ? (player as ObjectCollision).rectCollision.center
          : player.position.center;

      Offset playerPosition = _getCenterPositionByTile(positionPlayer);

      Offset targetPosition = _getCenterPositionByTile(finalPosition);

      int rows = (playerPosition.dy > targetPosition.dy
              ? playerPosition.dy
              : targetPosition.dy)
          .toInt();
      int columns = (playerPosition.dx > targetPosition.dx
              ? playerPosition.dx
              : targetPosition.dx)
          .toInt();

      List<Offset> barriers = gameRef.visibleCollisions().map((e) {
        return _getCenterPositionByTile(e.position.center);
      }).toList();

      List<Offset> result = [];
      List<Offset> path = [];

      if (barriers.contains(targetPosition)) {
        return;
      }

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
          return Offset(e.dx * tileSize, e.dy * tileSize)
              .translate(tileSize / 2, tileSize / 2);
        }).toList();

        _currentPath = path;
      } catch (e) {
        print('ERROR(AStar):$e');
      }
      gameRef.map.setLinePath(path, pathLineColor, pathLineStrokeWidth);
    }
  }

  double get tileSize {
    if (gameRef.map.tiles.isNotEmpty) {
      return gameRef.map.tiles.first.width;
    }
    return 0.0;
  }

  Offset _getCenterPositionByTile(Offset center) {
    return Offset(
      (center.dx / tileSize).floor().toDouble(),
      (center.dy / tileSize).floor().toDouble(),
    );
  }
}
