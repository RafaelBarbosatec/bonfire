import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flame/game.dart';
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
  final Camera camera;
  final Vector2 gameSize;
  final double zoom;

  MiniMapCanvas(this.components, this.camera, this.gameSize, {this.zoom = 1});

  @override
  void paint(Canvas canvas, Size size) {
    double minnor = min(gameSize.x, gameSize.y);
    double scale = size.width / minnor * zoom;
    canvas.translate(
        camera.position.x * scale * -1, camera.position.y * scale * -1);
    canvas.save();
    canvas.scale(scale);
    components.forEach(
      (element) {
        if (element is ObjectCollision) {
          if (element is Player) {
            element.renderCollision(canvas, Colors.cyan);
          } else if (element is Ally) {
            element.renderCollision(canvas, Colors.yellow);
          } else if (element is Enemy) {
            element.renderCollision(canvas, Colors.red);
          } else if (element is Npc) {
            element.renderCollision(canvas, Colors.green);
          } else if (element is Tile || element is GameDecoration) {
            element.renderCollision(canvas, Colors.black);
          }
        }
      },
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MiniMapCanvas oldDelegate) {
    return true;
  }
}
