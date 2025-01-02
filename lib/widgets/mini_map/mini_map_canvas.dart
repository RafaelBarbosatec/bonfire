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
  final Iterable<TileComponent> tiles;
  final Vector2 cameraPosition;
  final Vector2 gameSize;
  final MiniMapCustomRender<TileComponent>? tileRender;
  final MiniMapCustomRender? componentsRender;
  final double zoom;

  MiniMapCanvas({
    required this.tiles,
    required this.components,
    required this.cameraPosition,
    required this.gameSize,
    this.zoom = 1,
    this.tileRender,
    this.componentsRender,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / gameSize.x;
    final scaleY = size.height / gameSize.y;
    final scale = max(scaleX, scaleY) * zoom;

    canvas.translate(
      -cameraPosition.x * scale + size.width / 2 - (gameSize.x * scale) / 2,
      -cameraPosition.y * scale + size.height / 2 - (gameSize.y * scale) / 2,
    );
    canvas.save();
    canvas.scale(scale);
    for (final element in tiles) {
      tileRender?.call(canvas, element);
    }
    for (final element in components) {
      componentsRender?.call(canvas, element);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MiniMapCanvas oldDelegate) {
    return true;
  }
}
