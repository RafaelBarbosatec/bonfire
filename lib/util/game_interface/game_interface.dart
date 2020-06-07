import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/game_component.dart';
import 'package:bonfire/util/game_interface/interface_component.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GameInterface extends GameComponent {
  List<InterfaceComponent> _components = List();

  @override
  bool isHud() => true;

  @override
  bool isTouchable = true;

  @override
  int priority() => 20;

  @override
  void render(Canvas c) {
    _components.forEach((i) => i.render(c));
    _drawFPS(c);
  }

  @override
  void update(double t) {
    _components.forEach((i) {
      i.gameRef = gameRef;
      i.update(t);
    });
  }

  void add(InterfaceComponent component) {
    removeById(component.id);
    _components.add(component);
  }

  void removeById(int id) {
    if (_components.isEmpty) return;
    _components.removeWhere((i) => i.id == id);
  }

  @override
  void handlerTapDown(int pointer, Offset position) {
    _components.forEach((i) => i.handlerTapDown(pointer, position));
    super.handlerTapDown(pointer, position);
  }

  @override
  void handlerTapUp(int pointer, Offset position) {
    _components.forEach((i) => i.handlerTapUp(pointer, position));
    super.handlerTapUp(pointer, position);
  }

  void _drawFPS(Canvas c) {
    if (gameRef?.showFPS == true && gameRef?.size != null) {
      double fps = gameRef.fps(100);
      TextConfig(color: getColorFps(fps), fontSize: 14).render(
        c,
        'FPS: ${fps.toStringAsFixed(2)}',
        Position(gameRef.size.width - 100, 20),
      );
    }
  }

  Color getColorFps(double fps) {
    Color color = Colors.red;

    if (fps >= 40) {
      color = Colors.orange;
    }

    if (fps >= 60) {
      color = Colors.green;
    }

    return color;
  }
}
