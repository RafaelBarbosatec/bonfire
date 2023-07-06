import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

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
/// on 12/04/22
class MiniMapCanvas extends CustomPainter {
  final Iterable<GameComponent> components;
  final Iterable<Tile> tiles;
  final Vector2 cameraPosition;
  final Vector2 playerPosition;
  final Vector2 gameSize;
  final MiniMapCustomRender<Tile>? tileRender;
  final MiniMapCustomRender? componentsRender;
  final double zoom;

  MiniMapCanvas({
    required this.tiles,
    required this.components,
    required this.cameraPosition,
    required this.playerPosition,
    required this.gameSize,
    this.zoom = 1,
    this.tileRender,
    this.componentsRender,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double scaleX = size.width / gameSize.x;
    double scaleY = size.height / gameSize.y;
    double scale = max(scaleX, scaleY) * zoom;

    // double restX = (gameSize.x * scale - size.width) / 2;
    // double restY = (gameSize.y * scale - size.height) / 2;

    canvas.translate(
      (cameraPosition.x * scale) * -1,
      (cameraPosition.y * scale) * -1,
    );
    canvas.save();
    canvas.scale(scale);
    for (var element in tiles) {
      tileRender?.call(canvas, element);
    }
    for (var element in components) {
      componentsRender?.call(canvas, element);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MiniMapCanvas oldDelegate) {
    return cameraPosition != oldDelegate.cameraPosition ||
        playerPosition != oldDelegate.playerPosition;
  }
}
