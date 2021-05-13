import 'dart:ui';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/mixins/movement.dart';
import 'package:flutter/material.dart';

mixin MoveToPositionAlongThePath on GameComponent {
  List<Offset> _currentPath = [];
  int _currentIndex = 0;
  double _speed = 0;
  Movement? _component;

  Color _pathLineColor = Colors.lightBlueAccent.withOpacity(0.5);
  double _pathLineStrokeWidth = 4;

  void setupMoveToPositionAlongThePath(Color pathLineColor,
      {double pathLineStrokeWidth = 4}) {
    _pathLineColor = pathLineColor;
    _pathLineStrokeWidth = pathLineStrokeWidth;
  }

  void moveAlongThePath(
    Vector2 position,
    double speed,
  ) {
    if (this is Movement) {
      _component = this as Movement;
      _calculatePath(position.toOffset());
      _currentIndex = 0;
      this._speed = speed;
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
    _component?.idle();
  }

  void _move(double dt) {
    double innerSpeed = _speed * dt;

    Vector2Rect componentPosition = position;
    if (this is ObjectCollision) {
      componentPosition = (this as ObjectCollision).rectCollision;
    }
    double diffX = _currentPath[_currentIndex].dx - componentPosition.center.dx;
    double diffY = _currentPath[_currentIndex].dy - componentPosition.center.dy;
    double displacementX = diffX.abs() > innerSpeed ? _speed : diffX.abs() / dt;
    double displacementY = diffY.abs() > innerSpeed ? _speed : diffY.abs() / dt;

    if (diffX.abs() < 0.5 && diffY.abs() < 0.5) {
      if (_currentIndex < _currentPath.length - 1) {
        _currentIndex++;
      } else {
        stopMoveAlongThePath();
      }
    } else {
      if (diffX > 0 && diffX.abs() > 0.5) {
        _component?.moveRight(displacementX);
      }
      if (diffX < 0 && diffX.abs() > 0.5) {
        _component?.moveLeft(displacementX);
      }

      if (diffY > 0 && diffY.abs() > 0.5) {
        _component?.moveDown(displacementY);
      }
      if (diffY < 0 && diffY.abs() > 0.5) {
        _component?.moveUp(displacementY);
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
          return Offset(e.dx * _tileSize, e.dy * _tileSize)
              .translate(_tileSize / 2, _tileSize / 2);
        }).toList();

        _currentPath = path;
        _currentIndex = 0;
      } catch (e) {
        print('ERROR(AStar):$e');
      }
      gameRef.map.setLinePath(path, _pathLineColor, _pathLineStrokeWidth);
    }
  }

  double get _tileSize {
    if (gameRef.map.tiles.isNotEmpty) {
      return gameRef.map.tiles.first.width;
    }
    return 0.0;
  }

  bool get isMovingAlongThePath => _currentPath.isNotEmpty;

  Offset _getCenterPositionByTile(Offset center) {
    return Offset(
      (center.dx / _tileSize).floor().toDouble(),
      (center.dy / _tileSize).floor().toDouble(),
    );
  }
}
